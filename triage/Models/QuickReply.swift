//
//  QuickReply.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import Foundation

struct QuickReply: Identifiable, Codable {
    let id = UUID()
    var title: String
    var message: String
    var isActive: Bool
    var dateCreated: Date
    
    init(title: String, message: String, isActive: Bool = true) {
        self.title = title
        self.message = message
        self.isActive = isActive
        self.dateCreated = Date()
    }
}