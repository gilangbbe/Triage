//
//  AddAppointmentViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 03/09/25.
//

import Foundation
import SwiftUI

@Observable
class AddAppointmentViewModel {
    var selectedPackage: Package? = nil {
        didSet {
            updateAvailableSlots()
        }
    }
    
    var selectedPatient: Patient? = nil
    var appointmentDate = Date() {
        didSet {
            updateAvailableSlots()
        }
    }
    
    var selectedTimeSlot: TimeSlotOption? = nil
    var availableTimeSlots: [TimeSlotOption] = []
    
    private let appointmentManager: AppointmentManager
    
    init(appointmentManager: AppointmentManager) {
        self.appointmentManager = appointmentManager
    }
    
    var canSaveAppointment: Bool {
        selectedPackage != nil && selectedPatient != nil && selectedTimeSlot != nil
    }
    
    var hasNoAvailableSlots: Bool {
        selectedPackage != nil && availableTimeSlots.isEmpty
    }
    
    func saveAppointment() -> Bool {
        guard let selectedPackage = selectedPackage,
              let selectedPatient = selectedPatient,
              let selectedTimeSlot = selectedTimeSlot else { 
            return false
        }
        
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
        return true
    }
    
    func updateAvailableSlots() {
        guard let selectedPackage = selectedPackage else {
            availableTimeSlots = []
            return
        }
        
        let department = selectedPackage.department
        let maxSlotsPerHour = department.maxSlot ?? 3
        
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
                appointment.package?.department.id == department.id
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
    var availableSlots: Int
    let maxSlots: Int
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        
        return "\(start) - \(end) (\(availableSlots)/\(maxSlots) Slots Available)"
    }
}
