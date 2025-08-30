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
    var date: Date
    var time: Date
    var consultation: Bool
    var department: Department?

    // Links
    var patient: Patient?
    var package: Package?

    init(id: UUID = UUID(),
         name: String,
         date: Date,
         time: Date,
         consultation: Bool,
         patient: Patient? = nil,
         package: Package? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.time = time
        self.consultation = consultation
        self.patient = patient
        self.package = package
    }
}


