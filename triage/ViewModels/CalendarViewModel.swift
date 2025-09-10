//
//  CalendarViewModel.swift
//  triage
//
//  Created by Hayya U on 08/09/25.
//

import Foundation
import SwiftData

@Observable
final class CalendarViewModel {
    enum Scope: String, CaseIterable, Equatable { case day, week }

    private let appointmentManager: AppointmentManager
    @ObservationIgnored private let cal = Calendar.current

    // MARK: - UI State
    var scope: Scope = .day
    var selectedDate: Date = .now
    var monthAnchor: Date = .now

    var appointments: [Appointment] = []

    init(appointmentManager: AppointmentManager = .shared) {
        self.appointmentManager = appointmentManager
    }

    // MARK: - Visible range
    var visibleInterval: DateInterval {
        switch scope {
        case .day:
            let start = cal.startOfDay(for: selectedDate)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .week:
            let start = cal.dateInterval(of: .weekOfYear, for: monthAnchor)!.start
            let end = cal.date(byAdding: .day, value: 7, to: start)!
            return DateInterval(start: start, end: end)
        }
    }

    var visibleAppointments: [Appointment] {
        let iv = visibleInterval
        return appointmentManager.appointments
            .filter { appointment in
                guard let timeSlot = appointment.timeSlot else { return false }
                return timeSlot.endTime > iv.start && timeSlot.startTime < iv.end
            }
            .sorted { appointment1, appointment2 in
                guard let timeSlot1 = appointment1.timeSlot,
                      let timeSlot2 = appointment2.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime
            }
    }

    func appointments(on day: Date) -> [Appointment] {
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        
        return appointmentManager.appointments
            .filter { appointment in
                guard let timeSlot = appointment.timeSlot else { return false }
                return timeSlot.startTime >= start && timeSlot.startTime < end
            }
            .sorted { appointment1, appointment2 in
                guard let timeSlot1 = appointment1.timeSlot,
                      let timeSlot2 = appointment2.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime
            }
    }

    var appointmentsByDay: [Date: [Appointment]] {
        Dictionary(grouping: visibleAppointments) { appointment in
            guard let timeSlot = appointment.timeSlot else { return Date.distantPast }
            return cal.startOfDay(for: timeSlot.date)
        }
    }

    func appointmentsByHour(on day: Date) -> [Int: [Appointment]] {
        Dictionary(grouping: appointments(on: day)) { appointment in
            guard let timeSlot = appointment.timeSlot else { return 0 }
            return cal.component(.hour, from: timeSlot.startTime)
        }
    }

    var nextUpcomingInView: Appointment? {
        let now = Date()
        return visibleAppointments
            .filter { 
                guard let timeSlot = $0.timeSlot else { return false }
                return timeSlot.startTime >= now 
            }
            .min { 
                guard let timeSlot1 = $0.timeSlot, let timeSlot2 = $1.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime 
            }
    }

    // Convenience mirrors if you still need them:
    var todaysAppointments: [Appointment] { appointments(on: Date()) }
    var upcomingAppointments: [Appointment] { 
        visibleAppointments.filter { 
            guard let timeSlot = $0.timeSlot else { return false }
            return timeSlot.startTime > Date() 
        } 
    }
    var completedAppointments: [Appointment] { 
        visibleAppointments.filter { 
            guard let timeSlot = $0.timeSlot else { return false }
            return timeSlot.endTime < Date() 
        } 
    }

    // You can keep this if other screens rely on a cached list,
    // but don't use it for Day/Week screens now that we fetch directly.
    func reload() {
        appointments = appointmentManager.appointments
            .filter { $0.timeSlot != nil }
            .sorted { appointment1, appointment2 in
                guard let timeSlot1 = appointment1.timeSlot,
                      let timeSlot2 = appointment2.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime
            }
    }

    @MainActor
    func reloadForVisibleInterval() {
        appointments = filter(appointmentManager.appointments, in: visibleInterval)
    }

    @MainActor
    func addAppointment(_ appointment: Appointment) {
        appointmentManager.addAppointment(appointment)
        reloadForVisibleInterval()
    }

    @MainActor
    func deleteAppointment(_ appointment: Appointment) {
        appointmentManager.deleteAppointment(appointment)
        reloadForVisibleInterval()
    }

    // MARK: - REMINDER LOG
    @MainActor func markReminded(_ appt: Appointment) {
        appt.isReminded = true
        appointmentManager.updateAppointment(appt)
        reloadForVisibleInterval()
        logReminderIfNeeded(for: appt)
    }
    
    private func shouldLogReminder(now: Date = Date(), start: Date, leadTime: TimeInterval = 2*60*60) -> Bool {
        now >= start.addingTimeInterval(-leadTime)
    }

    private func alreadyLoggedReminder(for appt: Appointment, in history: [History]) -> Bool {
        let patientName = appt.patient?.fullName ?? appt.name
        
        guard let timeSlot = appt.timeSlot else { return false }
        let dateStr = DateFormatter.with("dd MMMM yyyy").string(from: timeSlot.startTime)
        let timeStr = DateFormatter.with("HH:mm").string(from: timeSlot.startTime)

        return history.contains { h in
            switch h.type {
            case .patitentReminderNotification(let n, let d, let t):
                return n == patientName && d == dateStr && t == timeStr
            default:
                return false
            }
        }
    }

    private func logReminderIfNeeded(for appt: Appointment, historyManager: HistoryManager = .shared) {
        guard let timeSlot = appt.timeSlot else { return }
        let start = timeSlot.startTime
        guard shouldLogReminder(start: start) else { return }
        guard !alreadyLoggedReminder(for: appt, in: historyManager.history) else { return }

        let patientName = appt.patient?.fullName ?? appt.name
        let packageName = appt.package?.department?.name ?? appt.name

        let dateStr = DateFormatter.with("dd MMMM yyyy").string(from: start)
        let timeStr = DateFormatter.with("hh:mm a").string(from: start)

        let dateWithPackage = "\(dateStr) with \(packageName)"

        historyManager.logPatientReminderNotification(
            patientName: patientName,
            appointmentDate: dateWithPackage,
            AppointmentTime: timeStr
        )
    }



    // MARK: - Local filter
    private func filter(_ appts: [Appointment], in iv: DateInterval) -> [Appointment] {
        appts
            .filter { 
                guard let timeSlot = $0.timeSlot else { return false }
                return timeSlot.startTime < iv.end && timeSlot.endTime > iv.start 
            }
            .sorted { 
                guard let timeSlot1 = $0.timeSlot, let timeSlot2 = $1.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime 
            }
    }
}
