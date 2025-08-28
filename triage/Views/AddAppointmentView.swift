//
//  AddAppointmentView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppointmentManager.self) private var appointmentManager
    @Environment(PatientManager.self) private var patientManager
    @Environment(PackageManager.self) private var packageManager
    
    @State private var title = ""
    @State private var selectedDepartment: Department = .mcu
    @State private var appointmentDate = Date()
    @State private var selectedPatient: Patient? = nil
    @State private var selectedPackage: Package? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appointment Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Department", selection: $selectedDepartment) {
                        ForEach(Department.allCases, id: \.self) { department in
                            Text(department.rawValue).tag(department)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $appointmentDate)
                }
                
                Section("Assignment") {
                    Picker("Patient", selection: $selectedPatient) {
                        Text("No Patient").tag(nil as Patient?)
                        ForEach(patientManager.patients, id: \.id) { patient in
                            Text(patient.fullName).tag(patient as Patient?)
                        }
                    }
                    
                    Picker("Package", selection: $selectedPackage) {
                        Text("No Package").tag(nil as Package?)
                        ForEach(packageManager.packages, id: \.id) { package in
                            Text(package.name).tag(package as Package?)
                        }
                    }
                }
            }
            .navigationTitle("Add Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveAppointment() {
        let newAppointment = Appointment(
            title: title,
            department: selectedDepartment,
            start: appointmentDate,
            patient: selectedPatient,
            package: selectedPackage
        )
        
        appointmentManager.addAppointment(newAppointment)
        dismiss()
    }
}

#Preview {
    AddAppointmentView()
        .environment(AppointmentManager.shared)
        .environment(PatientManager.shared)
        .environment(PackageManager.shared)
}
