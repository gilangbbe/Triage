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
    @ObservationIgnored private var context: ModelContext?

    var scope: Scope = .day
    var selectedDate: Date = .now
    var monthAnchor: Date = .now

    // (Optional) legacy cache—avoid relying on this for day/week screens
    var appointments: [Appointment] = []

    init(appointmentManager: AppointmentManager = .shared) {
        self.appointmentManager = appointmentManager
    }

    func setModelContext(_ ctx: ModelContext) {
        self.context = ctx
        appointmentManager.setModelContext(ctx)
        reload() // ok to keep if other parts still use 'appointments'
    }

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
        guard let ctx = context else { return [] }
        let iv = visibleInterval
        let predicate = #Predicate<Appointment> {
            $0.timeSlot.endTime > iv.start && $0.timeSlot.startTime < iv.end
        }
        let desc = FetchDescriptor<Appointment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timeSlot.startTime)]
        )
        return (try? ctx.fetch(desc)) ?? []
    }

    func appointments(on day: Date) -> [Appointment] {
        guard let ctx = context else { return [] }
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let predicate = #Predicate<Appointment> {
            $0.timeSlot.startTime >= start && $0.timeSlot.startTime < end
        }
        let desc = FetchDescriptor<Appointment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timeSlot.startTime)]
        )
        return (try? ctx.fetch(desc)) ?? []
    }

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

    // Convenience mirrors if you still need them:
    var todaysAppointments: [Appointment] { appointments(on: Date()) }
    var upcomingAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.startTime > Date() } }
    var completedAppointments: [Appointment] { visibleAppointments.filter { $0.timeSlot.endTime < Date() } }

    // You can keep this if other screens rely on a cached list,
    // but don't use it for Day/Week screens now that we fetch directly.
    func reload() {
        appointments = appointmentManager.appointments
    }

    // Mutations
    func addAppointment(_ appointment: Appointment) {
        appointmentManager.addAppointment(appointment)
        try? context?.save()
    }

    func deleteAppointment(_ appointment: Appointment) {
        appointmentManager.deleteAppointment(appointment)
        try? context?.save()
    }

    // ✅ Persist a reminder toggle
    func markReminded(_ appt: Appointment) {
        appt.isReminded = true
        try? context?.save()
    }

    // Helper if you still need a filter on arrays somewhere
    private func filter(_ appts: [Appointment], in iv: DateInterval) -> [Appointment] {
        appts
            .filter { $0.timeSlot.startTime < iv.end && $0.timeSlot.endTime > iv.start }
            .sorted { $0.timeSlot.startTime < $1.timeSlot.startTime }
    }
}
