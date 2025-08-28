//
//  AddPatientView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PatientManager.self) private var patientManager
    
    @State private var fullName = ""
    @State private var nationalID = ""
    @State private var dateOfBirth = Date()
    @State private var selectedGender: Gender? = nil
    @State private var placeOfBirth = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    
                    TextField("National ID (NIK)", text: $nationalID)
                        .keyboardType(.numberPad)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    
                    Picker("Gender", selection: $selectedGender) {
                        Text("Select Gender").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender as Gender?)
                        }
                    }
                    
                    TextField("Place of Birth", text: $placeOfBirth)
                }
                
                Section("Contact Information") {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Patient")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePatient()
                    }
                    .disabled(fullName.isEmpty)
                }
            }
        }
    }
    
    private func savePatient() {
        let newPatient = Patient(fullName: fullName)
        newPatient.nationalID = nationalID.isEmpty ? nil : nationalID
        newPatient.dateOfBirth = dateOfBirth
        newPatient.gender = selectedGender
        newPatient.placeOfBirth = placeOfBirth.isEmpty ? nil : placeOfBirth
        newPatient.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
        newPatient.address = address.isEmpty ? nil : address
        newPatient.registeredAt = Date()
        
        patientManager.addPatient(newPatient)
        dismiss()
    }
}

#Preview {
    AddPatientView()
        .environment(PatientManager.shared)
}
