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

    // Many-to-many relationship with patients
    var patients: [Patient] = []

    init(id: UUID = UUID(), name: String, descriptionText: String? = nil) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
    }
}
