//
//  AddAppointmentView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppointmentManager.self) private var appointmentManager
    @Environment(PatientManager.self) private var patientManager
    @Environment(PackageManager.self) private var packageManager
    
    @State private var selectedPackage: Package? = nil
    @State private var selectedPatient: Patient? = nil
    @State private var appointmentDate = Date()
    @State private var selectedTimeSlot: TimeSlotOption? = nil
    @State private var availableTimeSlots: [TimeSlotOption] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Package Selection") {
                    Picker("Package", selection: $selectedPackage) {
                        Text("Select Package").tag(nil as Package?)
                        ForEach(packageManager.packages, id: \.id) { package in
                            Text("\(package.name) - \(package.department.name)")
                                .tag(package as Package?)
                        }
                    }
                    .onChange(of: selectedPackage) { _, _ in
                        updateAvailableSlots()
                    }
                }
                
                Section("Patient Selection") {
                    Picker("Patient", selection: $selectedPatient) {
                        Text("Select Patient").tag(nil as Patient?)
                        ForEach(patientManager.patients, id: \.id) { patient in
                            Text(patient.fullName).tag(patient as Patient?)
                        }
                    }
                }
                
                Section("Schedule") {
                    DatePicker("Date", selection: $appointmentDate, displayedComponents: .date)
                        .onChange(of: appointmentDate) { _, _ in
                            updateAvailableSlots()
                        }
                    
                    if !availableTimeSlots.isEmpty {
                        Picker("Time & Available Slots", selection: $selectedTimeSlot) {
                            Text("Select Time Slot").tag(nil as TimeSlotOption?)
                            ForEach(availableTimeSlots, id: \.id) { slot in
                                Text(slot.displayText).tag(slot as TimeSlotOption?)
                            }
                        }
                    } else if selectedPackage != nil {
                        Text("No available slots for this date")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Appointment")
            .onAppear {
                updateAvailableSlots()
            }
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
                    .disabled(!canSaveAppointment)
                }
            }
        }
    }
    
    private var canSaveAppointment: Bool {
        selectedPackage != nil && selectedPatient != nil && selectedTimeSlot != nil
    }
    
    private func saveAppointment() {
        guard let selectedPackage = selectedPackage,
              let selectedPatient = selectedPatient,
              let selectedTimeSlot = selectedTimeSlot else { return }
        
        // Create TimeSlot
        let timeSlot = TimeSlot(
            date: appointmentDate,
            startTime: selectedTimeSlot.startTime,
            endTime: selectedTimeSlot.endTime
        )
        
        let appointmentTitle = "\(selectedPatient.fullName) - \(selectedPackage.name)"
        
        let newAppointment = Appointment(
            name: appointmentTitle,
            date: appointmentDate,
            startTime: selectedTimeSlot.startTime,
            endTime: selectedTimeSlot.endTime,
            timeSlot: timeSlot,
            patient: selectedPatient,
            package: selectedPackage
        )
        
        appointmentManager.addAppointment(newAppointment)
        dismiss()
    }
    
    private func updateAvailableSlots() {
        guard let selectedPackage = selectedPackage else {
            availableTimeSlots = []
            return
        }
        
        let department = selectedPackage.department
        let maxSlotsPerHour = department.maxSlot ?? 3 // Default to 3 if not set
        
        // Generate time slots from 8 AM to 5 PM
        let calendar = Calendar.current
        let workingHours = Array(8...16) // 8 AM to 4 PM (5 PM end time)
        
        availableTimeSlots = workingHours.compactMap { hour in
            guard let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: appointmentDate),
                  let endTime = calendar.date(bySettingHour: hour + 1, minute: 0, second: 0, of: appointmentDate) else {
                return nil
            }
            
            // Count existing appointments for this time slot and department
            let existingAppointments = appointmentManager.appointments.filter { appointment in
                calendar.isDate(appointment.timeSlot.date, inSameDayAs: appointmentDate) &&
                appointment.timeSlot.startTime.timeIntervalSince1970 == startTime.timeIntervalSince1970 &&
                appointment.package.department.id == department.id
            }
            
            let bookedSlots = existingAppointments.count
            let availableSlots = maxSlotsPerHour - bookedSlots
            
            return TimeSlotOption(
                startTime: startTime,
                endTime: endTime,
                availableSlots: max(0, availableSlots),
                maxSlots: maxSlotsPerHour
            )
        }
        
        // Filter out fully booked slots
        availableTimeSlots = availableTimeSlots.filter { $0.availableSlots > 0 }
    }
}

// MARK: - Helper Models
struct TimeSlotOption: Identifiable, Hashable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let availableSlots: Int
    let maxSlots: Int
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        
        return "\(start) - \(end) (\(availableSlots)/\(maxSlots) Slots Available)"
    }
}

#Preview {
    AddAppointmentView()
        .environment(AppointmentManager.shared)
        .environment(PatientManager.shared)
        .environment(PackageManager.shared)
}
