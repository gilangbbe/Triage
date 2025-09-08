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

    // MARK: - Dependencies
    private let appointmentManager: AppointmentManager
    @ObservationIgnored private let cal = Calendar.current
    @ObservationIgnored private var context: ModelContext?

    // MARK: - UI State (single source of truth)
    var scope: Scope = .day
    var selectedDate: Date = .now
    var monthAnchor: Date = .now

    // MARK: - Local cache (view-facing)
    /// Keep a view-facing cache independent of the manager’s full list if needed.
    var appointments: [Appointment] = []

    // MARK: - Init
    init(appointmentManager: AppointmentManager = .shared) {
        self.appointmentManager = appointmentManager
    }

    /// Wire SwiftData once (e.g., from the root view’s `.task`)
    func setModelContext(_ ctx: ModelContext) {
        self.context = ctx
        appointmentManager.setModelContext(ctx)
        reload() // initial fill
    }

    // MARK: - Visible range
    var visibleInterval: DateInterval {
        switch scope {
        case .day:
            let start = cal.startOfDay(for: selectedDate)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .week:
            // Use week containing monthAnchor so header selection drives the grid
            let start = cal.dateInterval(of: .weekOfYear, for: monthAnchor)!.start
            let end = cal.date(byAdding: .day, value: 7, to: start)!
            return DateInterval(start: start, end: end)
        }
    }

    // MARK: - Derived views
    /// Appointments overlapping the current visible interval (day/week)
    var visibleAppointments: [Appointment] {
        filter(appointmentManager.appointments, in: visibleInterval)
    }

    /// Appointments strictly on a calendar day
    func appointments(on day: Date) -> [Appointment] {
        appointmentManager.appointments
            .filter { cal.isDate($0.timeSlot.date, inSameDayAs: day) }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    /// Appointments grouped by day for the current visible range
    var appointmentsByDay: [Date: [Appointment]] {
        Dictionary(grouping: visibleAppointments) {
            cal.startOfDay(for: $0.timeSlot.date)
        }
    }

    /// Appointments grouped by hour for a given day (0…23)
    func appointmentsByHour(on day: Date) -> [Int: [Appointment]] {
        Dictionary(grouping: appointments(on: day)) {
            cal.component(.hour, from: $0.timeSlot.startTime)
        }
    }

    /// Next upcoming appointment within the visible interval
    var nextUpcomingInView: Appointment? {
        let now = Date()
        return visibleAppointments
            .filter { $0.timeSlot.startTime >= now }
            .min { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

    // Convenience mirrors
    var todaysAppointments: [Appointment] { appointmentManager.todaysAppointments() }
    var upcomingAppointments: [Appointment] { appointmentManager.upcomingAppointments() }
    var completedAppointments: [Appointment] { appointmentManager.completedAppointments() }

    // MARK: - Loading
    /// Mirror manager cache (cheap). Good for small/medium data.
    func reload() {
        appointments = appointmentManager.appointments
    }

    /// Fetch only what’s needed for the current day/week (use for large data).
    func reloadForVisibleInterval() {
        guard let ctx = context else { return }
        let iv = visibleInterval
        let predicate = #Predicate<Appointment> {
            $0.timeSlot.endTime > iv.start && $0.timeSlot.startTime < iv.end
        }
        let desc = FetchDescriptor<Appointment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timeSlot.startTime)]
        )
        do {
            appointments = try ctx.fetch(desc)
        } catch {
            print("Interval fetch failed: \(error)")
            appointments = []
        }
    }

    // MARK: - Mutations (pass-through)
    func addAppointment(_ appointment: Appointment) {
        appointmentManager.addAppointment(appointment)
        reload()
    }

    func deleteAppointment(_ appointment: Appointment) {
        appointmentManager.deleteAppointment(appointment)
        reload()
    }

    // MARK: - Helpers
    private func filter(_ appts: [Appointment], in iv: DateInterval) -> [Appointment] {
        appts
            .filter { $0.timeSlot.startTime < iv.end && $0.timeSlot.endTime > iv.start }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }

//    // Optional: helper for a Monday-start week array (UI grids)
//    func weekDays(for anchor: Date) -> [Date] {
//        let weekday = cal.component(.weekday, from: anchor)
//        let monday = cal.date(
//            byAdding: .day,
//            value: -(weekday == 1 ? 6 : weekday - 2),
//            to: cal.startOfDay(for: anchor)
//        ) ?? anchor
//        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
//    }
}
