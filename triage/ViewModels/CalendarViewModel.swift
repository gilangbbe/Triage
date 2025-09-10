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

    // MARK: - Deps
    private let appointmentManager: AppointmentManager
    @ObservationIgnored private let cal = Calendar.current
    // Keep a reference only if other screens still rely on it for saving,
    // but reads should come from appointmentManager.appointments.
    @ObservationIgnored private var context: ModelContext?

    // MARK: - UI State
    var scope: Scope = .day
    var selectedDate: Date = .now
    var monthAnchor: Date = .now

    /// Optional cache used by some screens; for day/week you can fill this
    /// with just the visible slice via `reloadForVisibleInterval()`.
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

    // MARK: - Reads (derive from manager’s live list)
    /// Live view of appointments overlapping the current visible interval.
    var visibleAppointments: [Appointment] {
        filter(appointmentManager.appointments, in: visibleInterval)
    }

    /// Appointments strictly on a calendar day.
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
    /// Legacy: mirror the manager’s full list (keep if other screens expect it).
    func reload() {
        appointments = appointmentManager.appointments
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    /// Fill `appointments` with just the current visible day/week slice.
    @MainActor
    func reloadForVisibleInterval() {
        appointments = filter(appointmentManager.appointments, in: visibleInterval)
    }

    // MARK: - Mutations (always write via manager)
    @MainActor func addAppointment(_ appointment: Appointment) {
        appointmentManager.addAppointment(appointment)
        // manager reloads internally; keep local cache in sync if you use it
        reloadForVisibleInterval()
    }

    @MainActor func deleteAppointment(_ appointment: Appointment) {
        appointmentManager.deleteAppointment(appointment)
        reloadForVisibleInterval()
    }

    @MainActor func markReminded(_ appt: Appointment) {
        appt.isReminded = true
        appointmentManager.updateAppointment(appt) // persists + reloads internally
        // keep local cache in sync with the new state
        reloadForVisibleInterval()
    }

    // MARK: - Local filter
    private func filter(_ appts: [Appointment], in iv: DateInterval) -> [Appointment] {
        appts
            .filter { $0.timeSlot.startTime < iv.end && $0.timeSlot.endTime > iv.start }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    // Convenience mirrors (computed from manager / visible slice)
    var todaysAppointments: [Appointment] { appointments(on: Date()) }
    var upcomingAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.startTime > Date() } }
    var completedAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.endTime < Date() } }
}
