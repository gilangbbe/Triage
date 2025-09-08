//
//  TimeSlot.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 03/09/25.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class TimeSlot {
    var id: UUID = UUID()
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    // Inverse relationship for CloudKit
    @Relationship(deleteRule: .nullify, inverse: \Appointment.timeSlot)
    var appointments: [Appointment]? = []
    
    init(id: UUID = UUID(), date: Date, startTime: Date, endTime: Date) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
}
