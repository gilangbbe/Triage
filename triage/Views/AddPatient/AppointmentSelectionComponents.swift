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
    let onDelete: () -> Void
    
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
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: Step 1 – Package Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appointmentType == .doctor ? "Doctor's Appointment" : "Medical Service Unit")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color("TextPrimary"))
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField(appointmentType == .doctor ? "Search doctor name..." : "Search Medical Service Unit", text: $searchText)
                                    .font(.subheadline)
                                    .focused($isTextFieldFocused)
                                    .onTapGesture { isTextFieldFocused = true }
                                
                                if !searchText.isEmpty {
                                    Button { searchText = ""; selectedPackage = nil } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                            
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
                                .font(.subheadline)
                                .foregroundColor(Color("TextPrimary"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            }
                        }
                        
                        if let package = selectedPackage, !shouldShowPackageList {
                            HStack {
                                Text(package.department.name)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Color("TextPrimary"))

                                Text(" - ")

                                Text(package.name)
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextPrimary"))

                                Spacer()

                                Button {
                                    selectedPackage = nil
                                    searchText = ""
                                    isTextFieldFocused = true
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color("TextPrimary"))
                                }
                            }
                            .padding(10)
                            .background(Color("ButtonSecondary"))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color("TextPrimary"), lineWidth: 1)
                            )
                        }
                    }
                    
                    // MARK: Step 2 – Date Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATE".uppercased())
                            .font(.caption2)
                            .foregroundColor(selectedPackage != nil ? Color("TextPrimary") : .gray)
                        
                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color("TextPrimary")) // changes selected date color
                        .disabled(selectedPackage == nil || shouldShowPackageList)
                        .opacity((selectedPackage == nil || shouldShowPackageList) ? 0.6 : 1.0)
                        
//                        ZStack {
//                            DatePicker(
//                                "",
//                                selection: $selectedDate,
//                                in: Date()...,
//                                displayedComponents: .date
//                            )
//                            .labelsHidden()
//                            .datePickerStyle(.compact)
//                            .tint(Color("TextPrimary"))
//                            .opacity(0.02)
//
//                            // Custom styled date
//                            Text(selectedDate, formatter: dateFormatter)
//                                .font(.subheadline)
//                                .bold()
//                                .foregroundColor(Color("TextPrimary"))
//                                .allowsHitTesting(false) // don’t block taps
//                        }
//                        .background(Color(hex: "D9D9D9").opacity(0.2))
//                        .disabled(selectedPackage == nil || shouldShowPackageList)
//                        .opacity((selectedPackage == nil || shouldShowPackageList) ? 0.6 : 1.0)

                    }
                    
                    // MARK: Step 3 – Time Slot
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIME & AVAILABLE SLOT".uppercased())
                            .font(.caption2)
                            .foregroundColor(selectedPackage != nil ? Color("TextPrimary") : .gray)
                        
                        Button {
                            if selectedPackage != nil && !shouldShowPackageList {
                                showTimePicker = true
                            }
                        } label: {
                            HStack {
                                if let selected = selectedTimeSlot, selectedPackage != nil {
                                    Text(timeString(selected))
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(Color("TextPrimary"))
                                    Spacer()
                                    if appointmentType == .doctor {
                                        if (!isEditing) {
                                            Text(selected.availableSlots > 0 ? "Available" : "Unavailable")
                                                .font(.footnote)
                                                .foregroundColor(selected.availableSlots > 0 ? Color("TextPrimary") : .red)
                                        }
                                    } else {
                                        if (!isEditing) {
                                            Text(
                                                ("\(selected.availableSlots) \(selected.availableSlots > 1 ? "Slots Available" : "Slot Available")")
                                            )
                                            .font(.footnote)
                                            .foregroundColor(Color("TextPrimary"))
                                        }
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
                            .background(Color(hex: "D9D9D9").opacity(0.2))
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
                            ).presentationDetents([.height(345)])
                        }

                    }
                    
                    // Availability info
                    if isEditing {
                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                onDelete()
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color("ButtonDelete"))
                                .foregroundColor(Color("OutlineDelete"))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color("OutlineDelete"), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.top, 12)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // MARK: Overlay for Package List
                if shouldShowPackageList {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 82)
                        HStack {
                            VStack(spacing: 0) {
                                if filteredPackages.isEmpty {
                                    Text("No packages found")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.secondary)
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
                            
                            Spacer().frame(width: 0)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.1).onTapGesture { isTextFieldFocused = false })
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                        Text(isEditing
                             ? (appointmentType == .doctor ? "Edit Doctor Appointment" : "Edit Service Appointment")
                             : (appointmentType == .doctor ? "New Doctor Appointment" : "New Service Appointment")
                        )
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Add") {
                        if let package = selectedPackage, let timeSlot = selectedTimeSlot {
                            onSave(package, selectedDate, timeSlot)
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let editing = editingAppointment {
                    selectedPackage = editing.package
                    selectedDate = editing.date
                    selectedTimeSlot = editing.timeSlot
                }
            }
            .onChange(of: selectedDate) { date in
                if let package = selectedPackage {
                    if appointmentType == .doctor {
                        viewModel.updateAvailableDoctorTimeSlots(for: package, on: date)
                    } else {
                        viewModel.updateAvailableTimeSlots(for: package, on: date)
                    }
                }
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    
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
            
            if let editing = editingAppointment {
                if let idx = viewModel.availableTimeSlots.firstIndex(where: {
                    $0.startTime == editing.timeSlot.startTime &&
                    $0.endTime == editing.timeSlot.endTime
                }) {
                    selectedTimeSlot = viewModel.availableTimeSlots[idx]
                } else {
                    // fallback if slot no longer available
                    selectedTimeSlot = nil
                }
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
        return formatter.string(from: timeSlot.startTime)
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
                    .foregroundColor(Color("TextPrimary"))
                Text(" - ")
                    .foregroundColor(Color("TextPrimary"))
                Text(package.name)
                    .font(.subheadline)
                    .foregroundColor(Color("TextPrimary"))
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
            Picker("Time Slot", selection: $selectedIndex) {
                ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, timeSlot in
                    HStack {
                        Spacer()
                        Text(timeString(timeSlot))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(timeSlot.availableSlots > 0 ? .primary : .secondary)
                        Spacer()
                        if appointmentType == .doctor {
                            Text(timeSlot.availableSlots > 0 ? "Available" : "Unavailable")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(timeSlot.availableSlots > 0 ? .secondary : .red)
                        } else {
                            Text("\(timeSlot.availableSlots)/\(timeSlot.maxSlots) " +
                                 (timeSlot.availableSlots > 1 ? "Slots Available" : "Slot Available"))
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(timeSlot.availableSlots > 0 ? .secondary : .red)
                        }
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: .infinity)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .principal) {
                        Text("Pick a Time Slot")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
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
        .onAppear {
            if let current = selectedTimeSlot,
               let idx = timeSlots.firstIndex(where: {
                   $0.startTime == current.startTime &&
                   $0.endTime == current.endTime
               }) {
                selectedIndex = idx
            } else {
                selectedIndex = 0
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
