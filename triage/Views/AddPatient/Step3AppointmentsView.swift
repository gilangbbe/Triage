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
            
            // Title - matching old design
            Text(isStandaloneMode ? "Add Appointment" : "Patient Appointment")
                .font(.headline)
                .padding(.horizontal)
                .foregroundColor(Color(hex: "#0F0E46"))
            
            // Two Columns Layout - similar to old design
            HStack(alignment: .top, spacing: 16) {
                
                // MARK: - Medical Packages Column
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medical Service Packages")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(Color(hex: "#0F0E46"))
                    
                    AddRowButton(title: "+ Add Package") {
                        showAppointmentForm = true
                    }
                    
                    ScrollView {
                        ForEach(Array(viewModel.selectedAppointments.enumerated()), id: \.element.id) { index, appointment in
                            ModernAppointmentCard(
                                appointment: appointment,
                                onTap: {
                                    editingAppointment = appointment
                                    showAppointmentForm = true
                                },
                                onDelete: {
                                    viewModel.removeAppointmentSelection(at: index)
                                }
                            )
                            .padding(.bottom, 6)
                        }
                        
                        if viewModel.selectedAppointments.isEmpty {
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
                        .foregroundColor(Color(hex: "#0F0E46"))
                    
                    AddRowButton(title: "+ Add Doctor") {
                        showDoctorAppointmentForm = true
                    }
                    
                    ScrollView {
                        ForEach(Array(viewModel.selectedDoctorAppointments.enumerated()), id: \.element.id) { index, appointment in
                            ModernAppointmentCard(
                                appointment: appointment,
                                onTap: {
                                    editingDoctorAppointment = appointment
                                    showDoctorAppointmentForm = true
                                },
                                onDelete: {
                                    viewModel.removeDoctorAppointmentSelection(at: index)
                                }
                            )
                            .padding(.bottom, 6)
                        }
                        
                        if viewModel.selectedDoctorAppointments.isEmpty {
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
        .navigationTitle(isStandaloneMode ? "Add Appointment" : "Patient Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isStandaloneMode {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
            }
        }
        .sheet(isPresented: $showAppointmentForm) {
            AppointmentSelectionSheet(
                viewModel: viewModel,
                editingAppointment: editingAppointment,
                appointmentType: .package,
                onSave: { package, date, timeSlot in
                    if editingAppointment != nil {
                        // Handle editing logic here
                        editingAppointment = nil
                    } else {
                        if isStandaloneMode {
                            onAppointmentSaved?(package, date, timeSlot)
                            onDismiss?()
                        } else {
                            viewModel.addAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                        }
                    }
                    showAppointmentForm = false
                },
                onCancel: {
                    editingAppointment = nil
                }
            )
        }
        .sheet(isPresented: $showDoctorAppointmentForm) {
            AppointmentSelectionSheet(
                viewModel: viewModel,
                editingAppointment: editingDoctorAppointment,
                appointmentType: .doctor,
                onSave: { package, date, timeSlot in
                    if editingDoctorAppointment != nil {
                        // Handle editing logic here
                        editingDoctorAppointment = nil
                    } else {
                        if isStandaloneMode {
                            onAppointmentSaved?(package, date, timeSlot)
                            onDismiss?()
                        } else {
                            viewModel.addDoctorAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                        }
                    }
                    showDoctorAppointmentForm = false
                },
                onCancel: {
                    editingDoctorAppointment = nil
                }
            )
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
                    .foregroundColor(Color(hex: "#0F0E46"))
                    .padding(.vertical, 5)
                Spacer()
            }
            .background(Color(UIColor.systemGray5))
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
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Date - similar to old card style
                Text(dateString(appointment.date))
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color(hex: "#0F0E46"))
                Spacer()
                // Package Name
                let packageName = appointment.package?.name ?? "Unknown Package"
                let displayName = appointment.package?.department.name == "Doctor" ? "Dr. \(packageName)" : packageName
                Text(displayName)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#0F0E46"))
            }
            
            HStack {
                // Time - similar to old card style
                Text(timeString(appointment.date, timeSlot: appointment.timeSlot))
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color(hex: "#0F0E46"))
                Spacer()
                // Department tag - similar to old design
                Text(appointment.package?.department.name ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#0F0E46"))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(Color(hex: "#FFE4E4"))
                    .cornerRadius(3)
            }
            
            // Availability info
            HStack {
                if appointment.timeSlot.maxSlots == 1 {
                    Text("Doctor appointment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(appointment.timeSlot.availableSlots)/\(appointment.timeSlot.maxSlots) slots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
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
        if timeSlot.maxSlots == 1 { // This indicates it's a doctor appointment
            return formatter.string(from: timeSlot.startTime)
        } else {
            let endTime = formatter.string(from: timeSlot.endTime)
            return "\(formatter.string(from: timeSlot.startTime)) - \(endTime)"
        }
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
