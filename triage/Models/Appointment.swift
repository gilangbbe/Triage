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
    var title: String
    var department: Department
    var start: Date
    var status: AppointmentStatus

    // Links
    var patient: Patient?
    var package: Package?

    init(id: UUID = UUID(),
         title: String,
         department: Department,
         start: Date,
         status: AppointmentStatus = .scheduled,
         patient: Patient? = nil,
         package: Package? = nil) {
        self.id = id
        self.title = title
        self.department = department
        self.start = start
        self.status = status
        self.patient = patient
        self.package = package
    }
}

enum AppointmentStatus: String, Codable, CaseIterable {
    case scheduled
    case completed
    case cancelled
    case noShow
}

enum Department: String, Codable, CaseIterable {
    case mcu = "MCU"
    case radiology = "Radiology"
    case laboratory = "Laboratorium"
}
