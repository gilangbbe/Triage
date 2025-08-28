//
//  PatientManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class PatientManager {
    static let shared = PatientManager()
    
    var patients: [Patient] = []
    private var modelContext: ModelContext?
    
    // App Group for sharing data between main app and keyboard extension
    private var sharedUserDefaults: UserDefaults? {
        return AppConfiguration.sharedUserDefaults
    }
    
    private init() {
        // ModelContext will be set by the main app
        loadPatients()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadPatients() // Reload data with the new context
    }
    
    // MARK: - CRUD Operations
    func addPatient(_ patient: Patient) {
        guard let context = modelContext else { return }
        
        context.insert(patient)
        saveContext()
        loadPatients()
    }
    
    func updatePatient(_ patient: Patient) {
        saveContext()
        loadPatients()
    }
    
    func deletePatient(_ patient: Patient) {
        guard let context = modelContext else { return }
        
        context.delete(patient)
        saveContext()
        loadPatients()
    }
    
    func deletePatients(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let patient = patients[index]
            context.delete(patient)
        }
        saveContext()
        loadPatients()
    }
    
    func clearAllPatients() {
        guard let context = modelContext else { return }
        
        for patient in patients {
            context.delete(patient)
        }
        saveContext()
        loadPatients()
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
