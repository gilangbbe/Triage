//
//  NewStep3AppointmentsView.swift
//  triage
//
//  Created by GitHub Copilot on 03/09/25.
//

import SwiftUI

struct NewStep3AppointmentsView: View {
    @Bindable var viewModel: AddPatientViewModel
    @State private var showAppointmentForm = false
    @State private var selectedPackage: Package? = nil
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlotOption? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schedule Appointments")
                .font(.headline)
                .foregroundColor(Color(hex: "#0F0E46"))
            
            // Selected appointments list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.selectedAppointments.enumerated()), id: \.element.id) { index, appointment in
                        AppointmentSelectionCard(
                            appointment: appointment,
                            onDelete: {
                                viewModel.removeAppointmentSelection(at: index)
                            }
                        )
                    }
                    
                    if viewModel.selectedAppointments.isEmpty {
                        EmptyAppointmentState()
                    }
                }
            }
            
            Spacer()
            
            // Add appointment button
            Button(action: {
                showAppointmentForm = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Appointment")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#0F0E46"))
                .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showAppointmentForm) {
            AppointmentSelectionSheet(
                viewModel: viewModel,
                onSave: { package, date, timeSlot in
                    viewModel.addAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                    showAppointmentForm = false
                }
            )
        }
    }
}

// MARK: - Supporting Views
struct AppointmentSelectionCard: View {
    let appointment: AppointmentSelection
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.package.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#0F0E46"))
                
                Text(appointment.package.department.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(appointment.displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(appointment.timeSlot.availableSlots)/\(appointment.timeSlot.maxSlots) slots")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyAppointmentState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No appointments scheduled")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Add an appointment to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AppointmentSelectionSheet: View {
    @Bindable var viewModel: AddPatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPackage: Package? = nil
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlotOption? = nil
    
    let onSave: (Package, Date, TimeSlotOption) -> Void
    
    var canSave: Bool {
        selectedPackage != nil && selectedTimeSlot != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Package") {
                    Picker("Select Package", selection: $selectedPackage) {
                        Text("Select a package").tag(Package?.none)
                        ForEach(viewModel.availablePackages, id: \.id) { package in
                            VStack(alignment: .leading) {
                                Text(package.name)
                                Text(package.department.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(Package?.some(package))
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Date") {
                    DatePicker("Appointment Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                if selectedPackage != nil {
                    Section("Time Slot") {
                        if viewModel.availableTimeSlots.isEmpty {
                            Text("No available time slots for this date")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.availableTimeSlots, id: \.id) { timeSlot in
                                Button(action: {
                                    selectedTimeSlot = timeSlot
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(timeSlot.displayText)
                                                .foregroundColor(.primary)
                                            
                                            if timeSlot.availableSlots <= 2 {
                                                Text("Limited availability")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedTimeSlot?.id == timeSlot.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let package = selectedPackage,
                           let timeSlot = selectedTimeSlot {
                            onSave(package, selectedDate, timeSlot)
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onChange(of: selectedPackage) { package in
            if let package = package {
                viewModel.updateAvailableTimeSlots(for: package, on: selectedDate)
            }
            selectedTimeSlot = nil
        }
        .onChange(of: selectedDate) { date in
            if let package = selectedPackage {
                viewModel.updateAvailableTimeSlots(for: package, on: date)
            }
            selectedTimeSlot = nil
        }
        .onAppear {
            if let package = selectedPackage {
                viewModel.updateAvailableTimeSlots(for: package, on: selectedDate)
            }
        }
    }
}
