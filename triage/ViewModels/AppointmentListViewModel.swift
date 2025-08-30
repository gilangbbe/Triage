//
//  AppointmentListViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftUI

@Observable
class AppointmentListViewModel {
    var searchText = ""
    var selectedDepartment: Department? = nil
    var showingAddAppointment = false
    
    private let appointmentManager: AppointmentManager
    
    init(appointmentManager: AppointmentManager) {
        self.appointmentManager = appointmentManager
    }
    
    var filteredAppointments: [Appointment] {
        var appointments = appointmentManager.appointments
        
        // Apply search filter
        if !searchText.isEmpty {
            appointments = appointmentManager.searchAppointments(query: searchText)
        }
        
        return appointments
    }
    
    var todaysAppointments: [Appointment] {
        appointmentManager.todaysAppointments()
    }
    
    var upcomingAppointments: [Appointment] {
        appointmentManager.upcomingAppointments()
    }
    
    func addAppointment(_ appointment: Appointment) {
        appointmentManager.addAppointment(appointment)
    }
    
    func deleteAppointment(_ appointment: Appointment) {
        appointmentManager.deleteAppointment(appointment)
    }
    
    func deleteAppointments(at indexSet: IndexSet, from appointments: [Appointment]) {
        for index in indexSet {
            let appointment = appointments[index]
            appointmentManager.deleteAppointment(appointment)
        }
    }
}
