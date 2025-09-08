//
//  Department.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 03/09/25.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Department {
    var id: UUID = UUID()
    var name: String = ""
    var maxSlot: Int?

    @Relationship(deleteRule: .cascade, inverse: \Package.department)
    var package: [Package]?
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    init(id: UUID = UUID(), name: String, maxSlot: Int) {
        self.id = id
        self.name = name
        self.maxSlot = maxSlot
    }
}

