//
//  Package.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData

@Model
final class Package {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String?
    
    var department: Department
    
    // Many-to-many: assigned patients (can be empty)
    @Relationship(deleteRule: .nullify, inverse: \Patient.packages)
    var patients: [Patient] = []
    
    // One-to-many: appointments that use this package
    @Relationship(deleteRule: .cascade, inverse: \Appointment.package)
    var appointments: [Appointment] = []

    init(id: UUID = UUID(), name: String, department: Department, descriptionText: String? = nil) {
        self.id = id
        self.name = name
        self.department = department
        self.descriptionText = descriptionText
    }
}
