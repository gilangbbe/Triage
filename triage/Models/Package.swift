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

    init(id: UUID = UUID(), name: String, department: Department, descriptionText: String? = nil) {
        self.id = id
        self.name = name
        self.department = department
        self.descriptionText = descriptionText
    }
}
