//
//  AppointmentManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine
import CloudKit

@Observable
class AppointmentManager: CloudKitSyncable {
    typealias ModelType = Appointment
    
    static let shared = AppointmentManager()
    
    var appointments: [Appointment] = []
    private var modelContext: ModelContext?
    private let cloudKitHelper = CloudKitHelper.shared
    
    private init() {
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadAppointments() // Load any additional local data
        }
    }
    
    // MARK: - CRUD Operations
    func addAppointment(_ appointment: Appointment) {
        guard let context = modelContext else { return }
        
        context.insert(appointment)
        saveContext()
        loadAppointments()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(appointment)
        }
    }
    
    func updateAppointment(_ appointment: Appointment) {
        saveContext()
        loadAppointments()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(appointment)
        }
    }
    
    func deleteAppointment(_ appointment: Appointment) {
        guard let context = modelContext else { return }
        
        context.delete(appointment)
        saveContext()
        loadAppointments()
        
        // Delete from CloudKit
        Task {
            await deleteFromCloudKit(appointment)
        }
    }
    
    func deleteAppointments(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        var appointmentsToDelete: [Appointment] = []
        for index in indexSet {
            let appointment = appointments[index]
            appointmentsToDelete.append(appointment)
            context.delete(appointment)
        }
        saveContext()
        loadAppointments()
        
        // Delete from CloudKit
        Task {
            for appointment in appointmentsToDelete {
                await deleteFromCloudKit(appointment)
            }
        }
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
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: Appointment) async {
        let record = CKRecord(recordType: "Appointment", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["name"] = item.name
        
        // References to related records
        if let patient = item.patient {
            let patientRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: patient.id.uuidString), action: .deleteSelf)
            record["patient"] = patientRef
        }
        
        if let package = item.package {
            let packageRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: package.id.uuidString), action: .deleteSelf)
            record["package"] = packageRef
        }
        
        // TimeSlot data (embedded since TimeSlots are typically dynamic)
        if let timeSlot = item.timeSlot {
            record["date"] = timeSlot.date
            record["startTime"] = timeSlot.startTime
            record["endTime"] = timeSlot.endTime
        }
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync appointment to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: Appointment) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: Appointment.self)
        } catch {
            print("❌ Failed to delete appointment from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            let records = try await cloudKitHelper.fetchRecords(ofType: "Appointment")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if appointment already exists in SwiftData database
                        let appointmentId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        
                        // Query SwiftData directly to check for existing record
                        guard let context = modelContext else { continue }
                        
                        let descriptor = FetchDescriptor<Appointment>(
                            predicate: #Predicate<Appointment> { appointment in
                                appointment.id == appointmentId
                            }
                        )
                        
                        do {
                            let existingAppointments = try context.fetch(descriptor)
                            if existingAppointments.isEmpty {
                                // Find related records (patient and package must exist)
                                var patient: Patient?
                                var package: Package?
                                
                                if let patientRef = record["patient"] as? CKRecord.Reference,
                                   let patientId = UUID(uuidString: patientRef.recordID.recordName) {
                                    // Need to get patient from PatientManager
                                    patient = PatientManager.shared.patients.first { $0.id == patientId }
                                }
                                
                                if let packageRef = record["package"] as? CKRecord.Reference,
                                   let packageId = UUID(uuidString: packageRef.recordID.recordName) {
                                    // Need to get package from PackageManager
                                    package = PackageManager.shared.packages.first { $0.id == packageId }
                                }
                                
                                // Create TimeSlot from embedded data
                                var timeSlot: TimeSlot?
                                if let date = record["date"] as? Date,
                                   let startTime = record["startTime"] as? Date,
                                   let endTime = record["endTime"] as? Date {
                                    timeSlot = TimeSlot(date: date, startTime: startTime, endTime: endTime)
                                }
                                
                                if let patient = patient, let package = package, let timeSlot = timeSlot {
                                    // Only create if doesn't exist in database
                                    let appointment = Appointment(
                                        id: appointmentId,
                                        name: record["name"] as? String ?? "",
                                        date: timeSlot.date,
                                        startTime: timeSlot.startTime,
                                        endTime: timeSlot.endTime,
                                        timeSlot: timeSlot,
                                        patient: patient,
                                        package: package
                                    )
                                    
                                    context.insert(appointment)
                                    try context.save()
                                    print("✅ Added new appointment from CloudKit: \(appointment.name)")
                                } else {
                                    print("⚠️ Skipping appointment - missing patient/package/timeslot: \(record["name"] as? String ?? "Unknown")")
                                }
                            } else {
                                print("ℹ️ Appointment already exists locally: \(record["name"] as? String ?? "Unknown")")
                            }
                        } catch {
                            print("❌ Failed to check/save appointment from CloudKit: \(error)")
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download appointment: \(error.localizedDescription)")
                    }
                }
                loadAppointments() // Refresh the appointments array
            }
        } catch {
            print("❌ Failed to load appointments from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for appointment in appointments {
            await syncToCloudKit(appointment)
        }
    }
}
