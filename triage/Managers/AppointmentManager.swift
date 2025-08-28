//
//  AppointmentManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class AppointmentManager {
    static let shared = AppointmentManager()
    
    var appointments: [Appointment] = []
    private var modelContext: ModelContext?
    
    private init() {
        loadAppointments()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadAppointments()
    }
    
    // MARK: - CRUD Operations
    func addAppointment(_ appointment: Appointment) {
        guard let context = modelContext else { return }
        
        context.insert(appointment)
        saveContext()
        loadAppointments()
    }
    
    func updateAppointment(_ appointment: Appointment) {
        saveContext()
        loadAppointments()
    }
    
    func deleteAppointment(_ appointment: Appointment) {
        guard let context = modelContext else { return }
        
        context.delete(appointment)
        saveContext()
        loadAppointments()
    }
    
    func deleteAppointments(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let appointment = appointments[index]
            context.delete(appointment)
        }
        saveContext()
        loadAppointments()
    }
    
    // MARK: - Data Loading
    func loadAppointments() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Appointment>(
                sortBy: [SortDescriptor(\.start, order: .forward)]
            )
            appointments = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch appointments: \(error)")
            appointments = []
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Search and Filter
    func searchAppointments(query: String) -> [Appointment] {
        if query.isEmpty {
            return appointments
        }
        
        return appointments.filter { appointment in
            appointment.title.localizedCaseInsensitiveContains(query) ||
            appointment.patient?.fullName.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func filterAppointments(by status: AppointmentStatus) -> [Appointment] {
        return appointments.filter { $0.status == status }
    }
    
    func filterAppointments(by department: Department) -> [Appointment] {
        return appointments.filter { $0.department == department }
    }
    
    func todaysAppointments() -> [Appointment] {
        let calendar = Calendar.current
        let today = Date()
        
        return appointments.filter { appointment in
            calendar.isDate(appointment.start, inSameDayAs: today)
        }
    }
    
    func upcomingAppointments() -> [Appointment] {
        let now = Date()
        return appointments.filter { $0.start > now }
    }
    
    func appointmentsForPatient(_ patient: Patient) -> [Appointment] {
        return appointments.filter { $0.patient?.id == patient.id }
    }
}
