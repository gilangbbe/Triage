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
    enum Scope: String, CaseIterable, Equatable { case Day, Week }

    private let appointmentManager: AppointmentManager
    @ObservationIgnored private let cal = Calendar.current

    // MARK: - UI State
    var scope: Scope = .Day
    var selectedDate: Date = .now
    var monthAnchor: Date = .now

    var appointments: [Appointment] = []

    init(appointmentManager: AppointmentManager = .shared) {
        self.appointmentManager = appointmentManager
    }

    // MARK: - Visible range
    var visibleInterval: DateInterval {
        switch scope {
        case .Day:
            let start = cal.startOfDay(for: selectedDate)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .Week:
            let start = cal.dateInterval(of: .weekOfYear, for: monthAnchor)!.start
            let end = cal.date(byAdding: .day, value: 7, to: start)!
            return DateInterval(start: start, end: end)
        }
    }

    var visibleAppointments: [Appointment] {
        filter(appointmentManager.appointments, in: visibleInterval)
    }

    func appointments(on day: Date) -> [Appointment] {
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return appointmentManager.appointments
            .filter { $0.timeSlot.startTime >= start && $0.timeSlot.startTime < end }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    // MARK: - Grouped helpers
    var appointmentsByDay: [Date: [Appointment]] {
        Dictionary(grouping: visibleAppointments) {
            cal.startOfDay(for: $0.timeSlot.date)
        }
    }

    func appointmentsByHour(on day: Date) -> [Int: [Appointment]] {
        Dictionary(grouping: appointments(on: day)) {
            cal.component(.hour, from: $0.timeSlot.startTime)
        }
    }

    var nextUpcomingInView: Appointment? {
        let now = Date()
        return visibleAppointments
            .filter { $0.timeSlot.startTime >= now }
            .min { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    // MARK: - Public reloads
    func reload() {
        appointments = appointmentManager.appointments
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
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

        let dateStr = DateFormatter.with("dd MMMM yyyy").string(from: appt.timeSlot.startTime)
        let timeStr = DateFormatter.with("HH:mm").string(from: appt.timeSlot.startTime)

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
        let start = appt.timeSlot.startTime
        guard shouldLogReminder(start: start) else { return }
        guard !alreadyLoggedReminder(for: appt, in: historyManager.history) else { return }

        let patientName = appt.patient?.fullName ?? appt.name
        let packageName = appt.package?.department.name ?? appt.name

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
            .filter { $0.timeSlot.startTime < iv.end && $0.timeSlot.endTime > iv.start }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    var todaysAppointments: [Appointment] { appointments(on: Date()) }
    var upcomingAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.startTime > Date() } }
    var completedAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.endTime < Date() } }
}
