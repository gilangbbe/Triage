//
//  Appointment.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData

@Model
final class Appointment {
    @Attribute(.unique) var id: UUID
    var name: String
    
    // Links
    var patient: Patient
    
    var timeSlot: TimeSlot
    var package: Package

    init(id: UUID = UUID(),
         name: String,
         date: Date,
         startTime: Date,
         endTime: Date,
         timeSlot: TimeSlot,
         patient: Patient,
         package: Package) {
        self.id = id
        self.name = name
        self.timeSlot = timeSlot
        self.patient = patient
        self.package = package
    }
}


