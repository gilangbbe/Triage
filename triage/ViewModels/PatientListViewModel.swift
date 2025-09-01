//
//  PatientListViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftUI

@Observable
class PatientListViewModel {
    var searchText = ""
    var selectedGender: Gender? = nil
    var selectedLetter: String? = nil
    var showingAddPatient = false
    
    private let patientManager: PatientManager
    
    init(patientManager: PatientManager) {
        self.patientManager = patientManager
    }
    
    var filteredPatients: [Patient] {
        var patients = patientManager.patients
        
        // Apply search filter
        if !searchText.isEmpty {
            patients = patientManager.searchPatients(query: searchText)
        }
        
        // Apply gender filter
        if let gender = selectedGender {
            patients = patients.filter { $0.gender == gender }
        }
        
        if let letter = selectedLetter {
            patients = patients.filter { $0.firstLetter == letter }
        }
        
        return patients
    }
    
    var patientsGroupedByFirstLetter: [String: [Patient]] {
        Dictionary(grouping: filteredPatients) { patient in
            patient.sortKey
        }
    }
    
    func addPatient(_ patient: Patient) {
        patientManager.addPatient(patient)
    }
    
    func deletePatient(_ patient: Patient) {
        patientManager.deletePatient(patient)
    }
    
    func deletePatients(at indexSet: IndexSet, from patients: [Patient]) {
        for index in indexSet {
            let patient = patients[index]
            patientManager.deletePatient(patient)
        }
    }
}
