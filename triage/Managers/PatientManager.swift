//
//  PatientManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine
import CloudKit

@Observable
class PatientManager: CloudKitSyncable {
    typealias ModelType = Patient
    
    static let shared = PatientManager()
    
    var patients: [Patient] = []
    private var modelContext: ModelContext?
    private let cloudKitHelper = CloudKitHelper.shared
    
    // App Group for sharing data between main app and keyboard extension
    private var sharedUserDefaults: UserDefaults? {
        return AppConfiguration.sharedUserDefaults
    }
    
    private init() {
        // ModelContext will be set by the main app
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadPatients() // Load any additional local data
        }
    }
    
    // MARK: - CRUD Operations
    func addPatient(_ patient: Patient) {
        guard let context = modelContext else { return }
        
        context.insert(patient)
        saveContext()
        loadPatients()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(patient)
        }
    }
    
    func updatePatient(_ patient: Patient) {
        saveContext()
        loadPatients()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(patient)
        }
    }
    
    func deletePatient(_ patient: Patient) {
        guard let context = modelContext else { return }
        
        context.delete(patient)
        saveContext()
        loadPatients()
        
        // Delete from CloudKit
        Task {
            await deleteFromCloudKit(patient)
        }
    }
    
    func deletePatients(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        var patientsToDelete: [Patient] = []
        for index in indexSet {
            let patient = patients[index]
            patientsToDelete.append(patient)
            context.delete(patient)
        }
        saveContext()
        loadPatients()
        
        // Delete from CloudKit
        Task {
            for patient in patientsToDelete {
                await deleteFromCloudKit(patient)
            }
        }
    }
    
    func clearAllPatients() {
        guard let context = modelContext else { return }
        
        let patientsToDelete = patients
        for patient in patients {
            context.delete(patient)
        }
        saveContext()
        loadPatients()
        
        // Delete from CloudKit
        Task {
            for patient in patientsToDelete {
                await deleteFromCloudKit(patient)
            }
        }
    }
    
    // MARK: - Data Loading
    func loadPatients() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Patient>(
                sortBy: [SortDescriptor(\.fullName, order: .forward)]
            )
            patients = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch patients: \(error)")
            patients = []
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
    
    // MARK: - Keyboard Extension Integration
    func syncFromKeyboardExtension() {
        // Load any new patients from keyboard extension
        guard let sharedData = sharedUserDefaults?.data(forKey: AppConfiguration.SharedDataKeys.newPatients),
              let patientDataArray = try? JSONDecoder().decode([PatientData].self, from: sharedData),
              let context = modelContext else { return }
        
        // Get existing patient IDs
        let existingIDs = Set(patients.map { $0.id.uuidString })
        
        // Add new patients from keyboard extension
        for patientData in patientDataArray {
            if !existingIDs.contains(patientData.id) {
                let newPatient = Patient(
                    id: UUID(uuidString: patientData.id) ?? UUID(),
                    fullName: patientData.fullName
                )
                newPatient.nationalID = patientData.nationalID
                newPatient.dateOfBirth = patientData.dateOfBirth
                newPatient.gender = Gender(rawValue: patientData.gender ?? "") ?? nil
                newPatient.placeOfBirth = patientData.placeOfBirth
                newPatient.registeredAt = patientData.registeredAt
                newPatient.phoneNumber = patientData.phoneNumber
                newPatient.address = patientData.address
                
                context.insert(newPatient)
            }
        }
        
        // Clear the processed patients from shared container
        sharedUserDefaults?.removeObject(forKey: AppConfiguration.SharedDataKeys.newPatients)
        
        saveContext()
        loadPatients()
    }
    
    // MARK: - Search and Filter
    func searchPatients(query: String) -> [Patient] {
        if query.isEmpty {
            return patients
        }
        
        return patients.filter { patient in
            patient.fullName.localizedCaseInsensitiveContains(query) ||
            patient.nationalID?.localizedCaseInsensitiveContains(query) == true ||
            patient.phoneNumber?.localizedCaseInsensitiveContains(query) == true ||
            patient.address?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func filterPatientsByGender(_ gender: Gender) -> [Patient] {
        return patients.filter { $0.gender == gender }
    }
    
    func patientsGroupedByFirstLetter() -> [String: [Patient]] {
        return Dictionary(grouping: patients) { patient in
            patient.sortKey
        }
    }
    
    // MARK: - Quick Actions
    func createPatientFromText(_ text: String) -> Patient? {
        return Patient.parseFromText(text)
    }
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: Patient) async {
        let record = CKRecord(recordType: "Patient", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["fullName"] = item.fullName
        record["nationalID"] = item.nationalID
        record["dateOfBirth"] = item.dateOfBirth
        record["gender"] = item.gender?.rawValue
        record["placeOfBirth"] = item.placeOfBirth
        record["registeredAt"] = item.registeredAt
        record["phoneNumber"] = item.phoneNumber
        record["address"] = item.address
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync patient to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: Patient) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: Patient.self)
        } catch {
            print("❌ Failed to delete patient from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            let records = try await cloudKitHelper.fetchRecords(ofType: "Patient")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if patient already exists locally
                        let patientId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        if !patients.contains(where: { $0.id == patientId }) {
                            let patient = Patient(
                                id: patientId,
                                fullName: record["fullName"] as? String ?? ""
                            )
                            
                            patient.nationalID = record["nationalID"] as? String
                            patient.dateOfBirth = record["dateOfBirth"] as? Date
                            if let genderString = record["gender"] as? String {
                                patient.gender = Gender(rawValue: genderString)
                            }
                            patient.placeOfBirth = record["placeOfBirth"] as? String
                            patient.registeredAt = record["registeredAt"] as? Date
                            patient.phoneNumber = record["phoneNumber"] as? String
                            patient.address = record["address"] as? String
                            
                            // Add to local storage
                            if let context = modelContext {
                                context.insert(patient)
                                do {
                                    try context.save()
                                } catch {
                                    print("❌ Failed to save patient from CloudKit: \(error)")
                                }
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download patient: \(error.localizedDescription)")
                    }
                }
                loadPatients() // Refresh the patients array
            }
        } catch {
            print("❌ Failed to load patients from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for patient in patients {
            await syncToCloudKit(patient)
        }
    }
}

// MARK: - Data transfer model for keyboard extension
struct PatientData: Codable {
    let id: String
    var fullName: String
    var nationalID: String?
    var dateOfBirth: Date?
    var gender: String?
    var placeOfBirth: String?
    var registeredAt: Date?
    var phoneNumber: String?
    var address: String?
}
