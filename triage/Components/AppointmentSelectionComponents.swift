//
//  AppointmentSelectionComponents.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 06/09/25.
//

import SwiftUI

enum AppointmentType {
    case package
    case doctor
}

// MARK: - Appointment Selection Sheet
struct AppointmentSelectionSheet: View {
    @Bindable var viewModel: AddPatientViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPackage: Package? = nil
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlotOption? = nil
    @State private var showTimePicker = false
    
    // Search and filter states
    @State private var searchText = ""
    @State private var selectedFilter: String = "All"
    @State private var isSearchFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
    let editingAppointment: AppointmentSelection?
    let appointmentType: AppointmentType
    let onSave: (Package, Date, TimeSlotOption) -> Void
    let onCancel: () -> Void
    
    var canSave: Bool {
        selectedPackage != nil && selectedTimeSlot != nil
    }
    
    var isEditing: Bool {
        editingAppointment != nil
    }
    
    // Filtered packages for search
    var filteredPackages: [Package] {
        let basePackages = appointmentType == .doctor 
            ? viewModel.availablePackages.filter { $0.department.name == "Doctor" }
            : viewModel.availablePackages.filter { $0.department.name != "Doctor" }
        
        let filtered = basePackages.filter { package in
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
        let basePackages = appointmentType == .doctor 
            ? viewModel.availablePackages.filter { $0.department.name == "Doctor" }
            : viewModel.availablePackages.filter { $0.department.name != "Doctor" }
        return Array(Set(basePackages.map { $0.department.name })).sorted()
    }
    
    var shouldShowPackageList: Bool {
        isTextFieldFocused || !searchText.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    
                    // Step 1: Package Selection with Search & Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appointmentType == .doctor ? "Doctor's Appointment" : "Medical Service Package")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(hex: "#0F0E46"))
                        
                        // Search and Filter Row
                        HStack {
                            // Search TextField
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField(appointmentType == .doctor ? "Search doctor name..." : "Search medical service package...", text: $searchText)
                                    .font(.subheadline)
                                    .focused($isTextFieldFocused)
                                    .onTapGesture {
                                        isTextFieldFocused = true
                                    }
                                
                                // Clear button
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                        selectedPackage = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                            
                            // Filter Menu
                            Menu {
                                Button("All") { selectedFilter = "All" }
                                ForEach(uniqueDepartments, id: \.self) { dept in
                                    Button(dept) { selectedFilter = dept }
                                }
                            } label: {
                                HStack {
                                    Text(selectedFilter)
                                        .font(.subheadline)
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(Color(hex: "#0F0E46"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            }
                        }
                        
                        // Selected Package Display (when not searching)
                        if let package = selectedPackage, !shouldShowPackageList {
                            HStack {
                                Text(package.department.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#0F0E46"))
                                Text(" - ")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#0F0E46"))
                                Text(package.name)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#0F0E46"))
                                Spacer()
                                Button {
                                    selectedPackage = nil
                                    searchText = ""
                                    isTextFieldFocused = true
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(6)
                        }
                    }
                    
                    // Step 2: Date (always visible, disabled when no package selected)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATE".uppercased())
                            .font(.caption2)
                            .foregroundColor(selectedPackage != nil ? Color(hex: "#0F0E46") : .gray)
                        
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
                        .disabled(selectedPackage == nil || shouldShowPackageList)
                        .opacity((selectedPackage == nil || shouldShowPackageList) ? 0.6 : 1.0)
                    }
                    
                    // Step 3: Time (always visible, disabled when no package selected)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIME & AVAILABLE SLOT".uppercased())
                            .font(.caption2)
                            .foregroundColor(selectedPackage != nil ? Color(hex: "#0F0E46") : .gray)
                        
                        Button {
                            if selectedPackage != nil && !shouldShowPackageList {
                                showTimePicker = true
                            }
                        } label: {
                            HStack {
                                if let selected = selectedTimeSlot, selectedPackage != nil {
                                    Text(timeString(selected))
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    Spacer()
                                    if appointmentType == .doctor {
                                        Text(selected.availableSlots > 0 ? "Available" : "Unavailable")
                                            .font(.subheadline)
                                            .foregroundColor(selected.availableSlots > 0 ? .gray : .red)
                                    } else {
                                        Text("\(selected.availableSlots)/\(selected.maxSlots) Slot Available")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text(selectedPackage == nil ? "Select a \(appointmentType == .doctor ? "doctor" : "package") first" : "Pick a Time")
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
                        .disabled(selectedPackage == nil || shouldShowPackageList)
                        .opacity((selectedPackage == nil || shouldShowPackageList) ? 0.6 : 1.0)
                        .sheet(isPresented: $showTimePicker) {
                            TimeSlotPickerModal(
                                timeSlots: viewModel.availableTimeSlots,
                                selectedTimeSlot: $selectedTimeSlot,
                                isPresented: $showTimePicker,
                                appointmentType: appointmentType
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(isEditing ? (appointmentType == .doctor ? "Edit Doctor Appointment" : "Edit Service Appointment") : (appointmentType == .doctor ? "New Doctor Appointment" : "New Service Appointment"))
                .navigationBarTitleDisplayMode(.inline)
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
                
                // Package List Overlay (shows when searching or focused)
                if shouldShowPackageList {
                    VStack(spacing: 0) {
                        // Push overlay to below search field
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 82) // Height for title + search field
                        
                        // Package list positioned directly below search field
                        HStack {
                            VStack(spacing: 0) {
                                if filteredPackages.isEmpty {
                                    Text("No packages found")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    ScrollView {
                                        LazyVStack(spacing: 1) {
                                            ForEach(filteredPackages, id: \.id) { package in
                                                PackageListRow(package: package) {
                                                    selectedPackage = package
                                                    searchText = ""
                                                    isTextFieldFocused = false
                                                    selectedTimeSlot = nil
                                                    if appointmentType == .doctor {
                                                        viewModel.updateAvailableDoctorTimeSlots(for: package, on: selectedDate)
                                                    } else {
                                                        viewModel.updateAvailableTimeSlots(for: package, on: selectedDate)
                                                    }
                                                }
                                                Divider()
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 200)
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            // Spacer to align with filter button
                            Spacer().frame(width: 0)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .background(
                        Color.black.opacity(0.1)
                            .onTapGesture {
                                isTextFieldFocused = false
                            }
                    )
                }
            }
            .onAppear {
                setupInitialState()
            }
            .onChange(of: selectedDate) { date in
                handleDateChange(date)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func setupInitialState() {
        if let editing = editingAppointment {
            selectedPackage = editing.package
            selectedDate = editing.date
            selectedTimeSlot = editing.timeSlot
            searchText = ""
        }
        
        if let package = selectedPackage {
            if appointmentType == .doctor {
                viewModel.updateAvailableDoctorTimeSlots(for: package, on: selectedDate)
            } else {
                viewModel.updateAvailableTimeSlots(for: package, on: selectedDate)
            }
        }
    }
    
    private func handleDateChange(_ date: Date) {
        if let package = selectedPackage {
            if appointmentType == .doctor {
                viewModel.updateAvailableDoctorTimeSlots(for: package, on: date)
            } else {
                viewModel.updateAvailableTimeSlots(for: package, on: date)
            }
            selectedTimeSlot = nil // Reset time slot when date changes
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
        if appointmentType == .doctor {
            return formatter.string(from: timeSlot.startTime)
        } else {
            return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
        }
    }
}

// MARK: - Package List Row Component
struct PackageListRow: View {
    let package: Package
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(package.department.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#0F0E46"))
                Text(" - ")
                    .foregroundColor(Color(hex: "#0F0E46"))
                Text(package.name)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#0F0E46"))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Time Slot Picker Modal
struct TimeSlotPickerModal: View {
    let timeSlots: [TimeSlotOption]
    @Binding var selectedTimeSlot: TimeSlotOption?
    @Binding var isPresented: Bool
    let appointmentType: AppointmentType
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Apple-style picker
                Picker("Time Slot", selection: $selectedIndex) {
                    ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, timeSlot in
                        HStack(spacing: 12) {
                            // Time display
                            Text(timeString(timeSlot))
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(timeSlot.availableSlots > 0 ? .primary : .secondary)
                            
                            // Availability display
                            if appointmentType == .doctor {
                                Text(timeSlot.availableSlots > 0 ? "Available" : "Unavailable")
                                    .font(.title3)
                                    .foregroundColor(timeSlot.availableSlots > 0 ? .secondary : .red)
                            } else {
                                Text("\(timeSlot.availableSlots)/\(timeSlot.maxSlots) Slot Available")
                                    .font(.title3)
                                    .foregroundColor(timeSlot.availableSlots > 0 ? .secondary : .red)
                            }
                        }
                        .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 180)
            }
            .padding()
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
                        if selectedIndex < timeSlots.count && timeSlots[selectedIndex].availableSlots > 0 {
                            selectedTimeSlot = timeSlots[selectedIndex]
                        }
                        isPresented = false
                    }
                    .disabled(selectedIndex >= timeSlots.count || timeSlots[selectedIndex].availableSlots <= 0)
                }
            }
        }
        .presentationDetents([.height(400)])
        .onAppear {
            // Set initial selection based on current selectedTimeSlot
            if let current = selectedTimeSlot,
               let index = timeSlots.firstIndex(where: { $0.id == current.id }) {
                selectedIndex = index
            }
        }
    }
    
    private func timeString(_ timeSlot: TimeSlotOption) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if appointmentType == .doctor {
            return formatter.string(from: timeSlot.startTime)
        } else {
            return "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
        }
    }
}
