//
//  Notification.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 02/09/25.
//

import Foundation

enum HistoryType {
    case patientDataUpdate(customerCareName: String, patientName: String)
    case serviceChoiceUpdate(customerCareName: String, patientName: String, serviceChoice: String)
}

struct History {
    let id = UUID()
    let type: HistoryType
    let timestamp: Date
}
