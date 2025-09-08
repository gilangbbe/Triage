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
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            let fetchedAppointments = try context.fetch(descriptor)
            
            // Sort manually by timeSlot date since we can't sort optional relationships directly
            appointments = fetchedAppointments.sorted { appointment1, appointment2 in
                guard let date1 = appointment1.timeSlot?.date,
                      let date2 = appointment2.timeSlot?.date else {
                    return false
                }
                return date1 < date2
            }
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
            appointment.name.localizedCaseInsensitiveContains(query) ||
            ((appointment.patient?.fullName.localizedCaseInsensitiveContains(query)) != nil)
        }
    }
    
    func filterAppointments(by department: Department) -> [Appointment] {
        return appointments.filter { $0.package?.department?.id == department.id }
    }
    
    func todaysAppointments() -> [Appointment] {
        let calendar = Calendar.current
        let today = Date()
        
        return appointments.filter { appointment in
            guard let timeSlot = appointment.timeSlot else { return false }
            return calendar.isDate(timeSlot.date, inSameDayAs: today)
        }
    }
    
    func upcomingAppointments() -> [Appointment] {
        let now = Date()
        return appointments.filter { 
            guard let timeSlot = $0.timeSlot else { return false }
            return timeSlot.startTime > now 
        }
    }
    
    func completedAppointments() -> [Appointment] {
        let now = Date()
        return appointments.filter { 
            guard let timeSlot = $0.timeSlot else { return false }
            return timeSlot.endTime < now 
        }
    }
    
    func appointmentsForPatient(_ patient: Patient) -> [Appointment] {
        return appointments.filter { $0.patient?.id == patient.id }
    }
}
