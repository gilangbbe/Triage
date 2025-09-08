//
//  AddAppointmentView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PatientManager.self) private var patientManager
    @Environment(PackageManager.self) private var packageManager
    
    @State private var viewModel: AddAppointmentViewModel
    
    init(appointmentManager: AppointmentManager) {
        self._viewModel = State(initialValue: AddAppointmentViewModel(appointmentManager: appointmentManager))
    }
    
    var body: some View {
        NavigationView {
            Form {
                PackageSelectionSection(
                    packages: packageManager.packages,
                    selectedPackage: $viewModel.selectedPackage
                )
                
                PatientSelectionSection(
                    patients: patientManager.patients,
                    selectedPatient: $viewModel.selectedPatient
                )
                
                ScheduleSection(
                    appointmentDate: $viewModel.appointmentDate,
                    selectedTimeSlot: $viewModel.selectedTimeSlot,
                    availableTimeSlots: viewModel.availableTimeSlots,
                    hasNoAvailableSlots: viewModel.hasNoAvailableSlots
                )
            }
            .navigationTitle("Add Appointment")
            .onAppear {
                viewModel.updateAvailableSlots()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveAppointment() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSaveAppointment)
                }
            }
        }
    }
}

// MARK: - View Components
struct PackageSelectionSection: View {
    let packages: [Package]
    @Binding var selectedPackage: Package?
    
    var body: some View {
        Section("Package Selection") {
            Picker("Package", selection: $selectedPackage) {
                Text("Select Package").tag(nil as Package?)
                ForEach(packages, id: \.id) { package in
                    Text("\(package.name) - \(package.department.name)")
                        .tag(package as Package?)
                }
            }
        }
    }
}

struct PatientSelectionSection: View {
    let patients: [Patient]
    @Binding var selectedPatient: Patient?
    
    var body: some View {
        Section("Patient Selection") {
            Picker("Patient", selection: $selectedPatient) {
                Text("Select Patient").tag(nil as Patient?)
                ForEach(patients, id: \.id) { patient in
                    Text(patient.fullName).tag(patient as Patient?)
                }
            }
        }
    }
}

struct ScheduleSection: View {
    @Binding var appointmentDate: Date
    @Binding var selectedTimeSlot: TimeSlotOption?
    let availableTimeSlots: [TimeSlotOption]
    let hasNoAvailableSlots: Bool
    
    var body: some View {
        Section("Schedule") {
            DatePicker("Date", selection: $appointmentDate, displayedComponents: .date)
            
            if !availableTimeSlots.isEmpty {
                Picker("Time & Available Slots", selection: $selectedTimeSlot) {
                    Text("Select Time Slot").tag(nil as TimeSlotOption?)
                    ForEach(availableTimeSlots, id: \.id) { slot in
                        Text(slot.displayText).tag(slot as TimeSlotOption?)
                    }
                }
            } else if hasNoAvailableSlots {
                Text("No available slots for this date")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AddAppointmentView(appointmentManager: AppointmentManager.shared)
        .environment(PatientManager.shared)
        .environment(PackageManager.shared)
}
