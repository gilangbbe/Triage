//
//  Step3AppointmentsView.swift
//  triage
//
//  Created by Chiquitta Kellie on 03/09/25.
//

import SwiftUI

struct Step3AppointmentsView: View {
    @Bindable var viewModel: AddPatientViewModel
    @State private var showAppointmentForm = false
    @State private var editingAppointment: AppointmentSelection? = nil
    @State private var showDoctorAppointmentForm = false
    @State private var editingDoctorAppointment: AppointmentSelection? = nil
    
    // Optional parameters for standalone mode (when used from PatientDetailView)
    let isStandaloneMode: Bool
    let patient: Patient?
    let onAppointmentSaved: ((Package, Date, TimeSlotOption) -> Void)?
    let onDismiss: (() -> Void)?
    
    // Local state for standalone mode appointments
    @State private var standalonePackageAppointments: [AppointmentSelection] = []
    @State private var standaloneDoctorAppointments: [AppointmentSelection] = []
    
    // Computed properties to get appropriate appointments based on mode
    private var packageAppointments: [AppointmentSelection] {
        isStandaloneMode ? standalonePackageAppointments : viewModel.selectedAppointments
    }
    
    private var doctorAppointments: [AppointmentSelection] {
        isStandaloneMode ? standaloneDoctorAppointments : viewModel.selectedDoctorAppointments
    }
    
    init(
        viewModel: AddPatientViewModel,
        isStandaloneMode: Bool = false,
        patient: Patient? = nil,
        onAppointmentSaved: ((Package, Date, TimeSlotOption) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.isStandaloneMode = isStandaloneMode
        self.patient = patient
        self.onAppointmentSaved = onAppointmentSaved
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Done and Cancel buttons for standalone mode
            if isStandaloneMode {
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                    Spacer()
                    
                    Button("Done") {
                        onDismiss?()
                    }
                }
            }
            
            // Title - matching old design
            Text(isStandaloneMode ? "Add Appointment" : "Patient Appointment")
                .font(.headline)
                .padding(.horizontal)
                .foregroundColor(Color("TextPrimary"))
            
            // Two Columns Layout - similar to old design
            HStack(alignment: .top, spacing: 16) {
                
                // MARK: - Medical Packages Column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medical Service Unit")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(Color("TextPrimary"))
                    
                    AddRowButton(title: "+ Add Package") {
                        showAppointmentForm = true
                    }
                    
                    ScrollView {
                        ForEach(Array(packageAppointments.enumerated()), id: \.element.id) { index, appointment in
                            ModernAppointmentCard(
                                appointment: appointment,
                                onTap: {
                                    editingAppointment = appointment
                                    showAppointmentForm = true
                                },
                            )
                            .padding(.bottom, 6)
                        }
                        
                        if packageAppointments.isEmpty {
                            EmptyAppointmentState()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: .infinity)
                
                // MARK: - Doctor Appointment Column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Doctor's Appointment")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(Color("TextPrimary"))
                    
                    AddRowButton(title: "+ Add Doctor") {
                        showDoctorAppointmentForm = true
                    }
                    
                    ScrollView {
                        ForEach(Array(doctorAppointments.enumerated()), id: \.element.id) { index, appointment in
                            ModernAppointmentCard(
                                appointment: appointment,
                                onTap: {
                                    editingDoctorAppointment = appointment
                                    showDoctorAppointmentForm = true
                                },
                            )
                            .padding(.bottom, 6)
                        }
                        
                        if doctorAppointments.isEmpty {
                            DoctorAppointmentPlaceholder()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showAppointmentForm) {
            AppointmentSelectionSheet(
                viewModel: viewModel,
                editingAppointment: editingAppointment,
                appointmentType: .package,
                onSave: { package, date, timeSlot in
                    if let editing = editingAppointment {
                        // Handle editing logic here
                        if isStandaloneMode {
                            if let index = standalonePackageAppointments.firstIndex(where: { $0.id == editing.id }) {
                                standalonePackageAppointments[index] = AppointmentSelection(
                                    id: editing.id,
                                    package: package,
                                    date: date,
                                    timeSlot: timeSlot
                                )
                            }
                        } else {
                            if let index = viewModel.selectedAppointments.firstIndex(where: { $0.id == editing.id }) {
                                viewModel.selectedAppointments[index] = AppointmentSelection(
                                    id: editing.id,
                                    package: package,
                                    date: date,
                                    timeSlot: timeSlot
                                )
                            }
                        }
                        editingAppointment = nil
                    } else {
                        if isStandaloneMode {
                            // Add to local state and save to patient
                            let appointmentSelection = AppointmentSelection(
                                package: package,
                                date: date,
                                timeSlot: timeSlot
                            )
                            standalonePackageAppointments.append(appointmentSelection)
                            onAppointmentSaved?(package, date, timeSlot)
                        } else {
                            viewModel.addAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                        }
                    }
                    showAppointmentForm = false
                },
                onCancel: {
                    editingAppointment = nil
                },
                onDelete: {
                    guard let editing = editingAppointment else { return }
                    if isStandaloneMode {
                        standalonePackageAppointments.removeAll(where: { $0.id == editing.id })
                        deleteFromPatientAppointments(editing)
                    } else {
                        viewModel.removeAppointmentSelection(by: editing.id)
                    }
                    editingAppointment = nil
                    showAppointmentForm = false
                }
            )
        }
        .sheet(isPresented: $showDoctorAppointmentForm) {
            AppointmentSelectionSheet(
                viewModel: viewModel,
                editingAppointment: editingDoctorAppointment,
                appointmentType: .doctor,
                onSave: { package, date, timeSlot in
                    if let editing = editingDoctorAppointment {
                        if isStandaloneMode {
                            if let index = standaloneDoctorAppointments.firstIndex(where: { $0.id == editing.id }) {
                                standaloneDoctorAppointments[index] = AppointmentSelection(
                                    id: editing.id,
                                    package: package,
                                    date: date,
                                    timeSlot: timeSlot
                                )
                            }
                        } else {
                            if let index = viewModel.selectedDoctorAppointments.firstIndex(where: { $0.id == editing.id }) {
                                viewModel.selectedDoctorAppointments[index] = AppointmentSelection(
                                    id: editing.id,
                                    package: package,
                                    date: date,
                                    timeSlot: timeSlot
                                )
                            }
                        }
                        editingDoctorAppointment = nil
                    } else {
                        if isStandaloneMode {
                            // Add to local state and save to patient
                            let appointmentSelection = AppointmentSelection(
                                package: package,
                                date: date,
                                timeSlot: timeSlot
                            )
                            standaloneDoctorAppointments.append(appointmentSelection)
                            onAppointmentSaved?(package, date, timeSlot)
                        } else {
                            viewModel.addDoctorAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                        }
                    }
                    showDoctorAppointmentForm = false
                },
                onCancel: {
                    editingDoctorAppointment = nil
                },
                onDelete: {
                    guard let editing = editingDoctorAppointment else { return }
                    if isStandaloneMode {
                        standaloneDoctorAppointments.removeAll(where: { $0.id == editing.id })
                        deleteFromPatientAppointments(editing)
                    } else {
                        viewModel.removeDoctorAppointmentSelection(by: editing.id)
                    }
                    editingDoctorAppointment = nil
                    showDoctorAppointmentForm = false
                }
            )
        }
        .onAppear {
            if isStandaloneMode, let patient = patient {
                populateExistingAppointments(for: patient)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func populateExistingAppointments(for patient: Patient) {
        // Get upcoming appointments only
        let upcomingAppointments = patient.appointments.filter { appointment in
            appointment.timeSlot.date >= Calendar.current.startOfDay(for: Date())
        }
        
        // Separate into packages and doctors
        for appointment in upcomingAppointments {
            guard let package = appointment.package else { continue }
            
            let timeSlotOption = TimeSlotOption(
                startTime: appointment.timeSlot.startTime,
                endTime: appointment.timeSlot.endTime,
                availableSlots: 1,
                maxSlots: 1
            )
            
            let appointmentSelection = AppointmentSelection(
                package: package,
                date: appointment.timeSlot.date,
                timeSlot: timeSlotOption
            )
            
            // Check if it's a doctor appointment or package appointment
            if package.department.name == "Doctor" {
                standaloneDoctorAppointments.append(appointmentSelection)
            } else {
                standalonePackageAppointments.append(appointmentSelection)
            }
        }
    }
    
    private func deleteFromPatientAppointments(_ appointmentSelection: AppointmentSelection) {
        guard let patient = patient else { return }
        
        // Find the matching appointment in the patient's appointments
        if let appointmentToDelete = patient.appointments.first(where: { appointment in
            appointment.timeSlot.date == appointmentSelection.date &&
            appointment.timeSlot.startTime == appointmentSelection.timeSlot.startTime &&
            appointment.package?.id == appointmentSelection.package?.id
        }) {
            // Remove from AppointmentManager
            AppointmentManager.shared.deleteAppointment(appointmentToDelete)
        }
    }
}

// MARK: - Add Row Button (from old design)
struct AddRowButton: View {
    var title: String = "+ Add"
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.footnote)
                    .foregroundColor(Color("TextPrimary"))
                    .padding(.vertical, 5)
                Spacer()
            }
            .background(Color("ButtonSecondary"))
            .cornerRadius(6)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// MARK: - Modern Appointment Card (inspired by old design)
struct ModernAppointmentCard: View {
    let appointment: AppointmentSelection
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Date - similar to old card style
                Text(dateString(appointment.date))
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                // Package Name
                let packageName = appointment.package?.name ?? "Unknown Package"
                let displayName = appointment.package?.department.name == "Doctor" ? "Dr. \(packageName)" : packageName
                Text(displayName)
                    .font(.subheadline)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            HStack {
                // Time - similar to old card style
                Text(timeString(appointment.date, timeSlot: appointment.timeSlot))
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                // Department tag - similar to old design
                Text(appointment.package?.department.name ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "0F0E46"))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(Color(hex: "#FFE4E4"))
                    .cornerRadius(3)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("CardBackground"))
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date, timeSlot: TimeSlotOption) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
    
        return formatter.string(from: timeSlot.startTime)
    }
}

// MARK: - Doctor Appointment Placeholder
struct DoctorAppointmentPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            
            Text("No doctor appointments")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Add a doctor to get started")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct EmptyAppointmentState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            
            Text("No appointments scheduled")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Add a package to get started")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    Step3AppointmentsView(viewModel: AddPatientViewModel(
        patientManager: PatientManager.shared, appointmentManager: AppointmentManager.shared, packageManager: PackageManager.shared
    ))
}
