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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Title - matching old design
            Text("Patient Appointment")
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
                        // TODO: Implement doctor appointment functionality
                    }
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Placeholder for future doctor appointments
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
                onSave: { package, date, timeSlot in
                    if editingAppointment != nil {
                        // Handle editing logic here
                        editingAppointment = nil
                    } else {
                        viewModel.addAppointmentSelection(package: package, date: date, timeSlot: timeSlot)
                    }
                    showAppointmentForm = false
                },
                onCancel: {
                    editingAppointment = nil
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
                Text(appointment.package.name)
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
                Text(appointment.package.department.name)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#0F0E46"))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(Color(hex: "#FFE4E4"))
                    .cornerRadius(3)
            }
            
            // Availability info
            HStack {
                Text("\(appointment.timeSlot.availableSlots)/\(appointment.timeSlot.maxSlots) slots")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            
            Text("Doctor appointments")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Coming soon")
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

struct AppointmentSelectionSheet: View {
    @Bindable var viewModel: AddPatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPackage: Package? = nil
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlotOption? = nil
    @State private var showPackageModal = false
    @State private var showTimePicker = false
    
    let editingAppointment: AppointmentSelection?
    let onSave: (Package, Date, TimeSlotOption) -> Void
    let onCancel: () -> Void
    
    var canSave: Bool {
        selectedPackage != nil && selectedTimeSlot != nil
    }
    
    var isEditing: Bool {
        editingAppointment != nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // Step 1: Package Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Medical Service Package")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(Color(hex: "#0F0E46"))
                    
                    Button(action: { showPackageModal = true }) {
                        HStack {
                            if selectedPackage == nil {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    Text("Select Medical Service Package")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            } else {
                                HStack {
                                    Text(selectedPackage?.department.name ?? "")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#0F0E46"))
                                    Text(" - ")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#0F0E46"))
                                    Text(selectedPackage?.name ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#0F0E46"))
                                }
                            }
                            Spacer()
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showPackageModal) {
                        PackageSearchModal(
                            viewModel: viewModel,
                            selectedPackage: $selectedPackage
                        )
                    }
                }
                
                // Step 2: Date
                VStack(alignment: .leading, spacing: 6) {
                    Text("DATE".uppercased())
                        .font(.caption2)
                        .foregroundColor(Color(hex: "#0F0E46"))
                    DatePicker(
                        dateString(selectedDate),
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.clear))
                    .cornerRadius(6)
                }
                
                // Step 3: Time
                VStack(alignment: .leading, spacing: 6) {
                    Text("TIME & AVAILABLE SLOT".uppercased())
                        .font(.caption2)
                        .foregroundColor(Color(hex: "#0F0E46"))
                    
                    Button {
                        showTimePicker = true
                    } label: {
                        HStack {
                            if let selected = selectedTimeSlot {
                                Text(timeString(selected))
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(selected.availableSlots)/\(selected.maxSlots) Slot Available")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Pick a Time")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                    .sheet(isPresented: $showTimePicker) {
                        TimeSlotPickerModal(
                            timeSlots: viewModel.availableTimeSlots,
                            selectedTimeSlot: $selectedTimeSlot,
                            isPresented: $showTimePicker
                        )
                    }
                    .disabled(selectedPackage == nil)
                    .opacity(selectedPackage == nil ? 0.6 : 1)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(isEditing ? "Edit Service Appointment" : "New Service Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Pre-populate if editing
                if let editing = editingAppointment {
                    selectedPackage = editing.package
                    selectedDate = editing.date
                    selectedTimeSlot = editing.timeSlot
                }
                
                if let package = selectedPackage {
                    viewModel.updateAvailableTimeSlots(for: package, on: selectedDate)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Add") {
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
    }
    
    // Helper functions
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private func timeString(_ timeSlot: TimeSlotOption) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
    }
}

// MARK: - Package Search Modal (inspired by ServiceUnitSearchModal)
struct PackageSearchModal: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: AddPatientViewModel
    @Binding var selectedPackage: Package?
    
    @State private var searchText = ""
    @State private var selectedFilter: String = "All"
    @State private var tempPackage: Package? = nil
    
    var filteredPackages: [Package] {
        let filtered = viewModel.availablePackages.filter { package in
            (selectedFilter == "All" || package.department.name == selectedFilter) &&
            (searchText.isEmpty || package.name.localizedCaseInsensitiveContains(searchText))
        }
        
        return filtered.sorted { (a, b) in
            if a.department.name == b.department.name {
                return a.name < b.name
            } else {
                return a.department.name < b.department.name
            }
        }
    }
    
    var uniqueDepartments: [String] {
        Array(Set(viewModel.availablePackages.map { $0.department.name })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search + filter
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search package...", text: $searchText)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Menu {
                        Button("All") { selectedFilter = "All" }
                        ForEach(uniqueDepartments, id: \.self) { dept in
                            Button(dept) { selectedFilter = dept }
                        }
                    } label: {
                        HStack {
                            Text(selectedFilter)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                // Package list
                List(filteredPackages) { package in
                    let isSelected = (tempPackage?.id == package.id)
                    HStack {
                        Text(package.department.name)
                            .foregroundColor(Color(hex: "#0F0E46"))
                        Text(" - ")
                            .foregroundColor(Color(hex: "#0F0E46"))
                        Text(package.name)
                            .foregroundColor(Color(hex: "#0F0E46"))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isSelected {
                            tempPackage = nil
                        } else {
                            tempPackage = package
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Medical Service Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select") {
                        selectedPackage = tempPackage
                        dismiss()
                    }
                    .disabled(tempPackage == nil)
                }
            }
            .onAppear {
                tempPackage = selectedPackage
            }
        }
    }
}

// MARK: - Time Slot Picker Modal (inspired by TimePickerModal)
struct TimeSlotPickerModal: View {
    let timeSlots: [TimeSlotOption]
    @Binding var selectedTimeSlot: TimeSlotOption?
    @Binding var isPresented: Bool
    
    @State private var tempSelection: TimeSlotOption?
    
    var body: some View {
        NavigationStack {
            List(timeSlots, id: \.id) { timeSlot in
                Button {
                    tempSelection = timeSlot
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(timeString(timeSlot))
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(timeSlot.displayText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if tempSelection?.id == timeSlot.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                }
                .disabled(timeSlot.availableSlots <= 0)
                .opacity(timeSlot.availableSlots > 0 ? 1.0 : 0.6)
            }
            .listStyle(.plain)
            .navigationTitle("Pick a Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        selectedTimeSlot = tempSelection
                        isPresented = false
                    }
                    .disabled(tempSelection == nil)
                }
            }
        }
        .presentationDetents([.height(300)])
        .onAppear {
            tempSelection = selectedTimeSlot
        }
    }
    
    private func timeString(_ timeSlot: TimeSlotOption) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
    }
}

#Preview {
    Step3AppointmentsView(viewModel: AddPatientViewModel(
        patientManager: PatientManager.shared, appointmentManager: AppointmentManager.shared, packageManager: PackageManager.shared
    ))
}
