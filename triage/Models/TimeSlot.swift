//
//  TimeSlot.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 03/09/25.
//

import Foundation
import SwiftData

@Model
final class TimeSlot {
    @Attribute(.unique) var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date
    
    init(id: UUID = UUID(), date: Date, startTime: Date, endTime: Date) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }
}
