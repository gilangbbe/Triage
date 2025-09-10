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
    var selectedDepartmentIndex = 0 // 0: All, 1: MCU, 2: Radiology, 3: Laboratory
    var showingAddPatient = false
    
    private let patientManager: PatientManager
    private let appointmentManager: AppointmentManager
    
    // Department mapping
    private let departments = ["All", "MCU", "Radiology", "Laboratory"]
    
    init(patientManager: PatientManager, appointmentManager: AppointmentManager = .shared) {
        self.patientManager = patientManager
        self.appointmentManager = appointmentManager
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
        
        // Apply letter filter
        if let letter = selectedLetter {
            patients = patients.filter { $0.firstLetter == letter }
        }
        
        // Apply department filter
        if selectedDepartmentIndex > 0 {
            let selectedDepartment = departments[selectedDepartmentIndex]
            patients = patients.filter { patient in
                hasAppointmentInDepartment(patient: patient, departmentName: selectedDepartment)
            }
        }
        
        return patients
    }
    
    private func hasAppointmentInDepartment(patient: Patient, departmentName: String) -> Bool {
        // Get all appointments for this patient from AppointmentManager
        let patientAppointments = appointmentManager.appointments.filter { $0.patient?.id == patient.id }
        
        // Check if any appointment belongs to the selected department
        return patientAppointments.contains { appointment in
            guard let department = appointment.package?.department else { return false }
            
            // Map department names to match segmented control
            switch departmentName {
            case "MCU":
                return department.name.localizedCaseInsensitiveContains("Medical Check Up") ||
                       department.name.localizedCaseInsensitiveContains("MCU")
            case "Radiology":
                return department.name.localizedCaseInsensitiveContains("Radiology") ||
                       department.name.localizedCaseInsensitiveContains("Radiologi")
            case "Laboratory":
                return department.name.localizedCaseInsensitiveContains("Laboratory") ||
                       department.name.localizedCaseInsensitiveContains("Laboratorium") ||
                       department.name.localizedCaseInsensitiveContains("Lab")
            default:
                return false
            }
        }
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
