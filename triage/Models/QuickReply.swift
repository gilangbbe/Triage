//
//  QuickReply.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class QuickReply {
    var id: UUID = UUID()
    var title: String = ""
    var message: String = ""
    var isActive: Bool = true
    var dateCreated: Date = Date()
    
    init(title: String, message: String, isActive: Bool = true) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.isActive = isActive
        self.dateCreated = Date()
    }
}