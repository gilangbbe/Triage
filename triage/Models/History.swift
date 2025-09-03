//
//  Notification.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 02/09/25.
//

import Foundation
import SwiftData

@Model
class History: ObservableObject {
    @Attribute(.unique) var id: UUID
    private var typeData: Data
    var type: HistoryType {
        get {
            try! JSONDecoder().decode(HistoryType.self, from: typeData)
        }
        set {
            typeData = try! JSONEncoder().encode(newValue)
        }
    }
    var timestamp: Date
    
    init(id: UUID = UUID(), type: HistoryType, timestamp: Date = Date()) {
        self.id = id
        self.typeData = try! JSONEncoder().encode(type)
        self.timestamp = timestamp
    }
}

enum HistoryType: Codable {
    case patientDataUpdate(customerCareName: String, patientName: String)
    case serviceChoiceUpdate(customerCareName: String, patientName: String, serviceChoice: String)
    case newPatient(patientName: String)
}

extension HistoryManager {
    func logPatientDataUpdate(customerCareName: String, patientName: String) {
        let newHistory = History(type: .patientDataUpdate(customerCareName: customerCareName, patientName: patientName))
        addHistory(newHistory)
    }
    
    func logServiceChoiceUpdate(customerCareName: String, patientName : String, serviceChoice: String) {
        let newHistory = History(type: .serviceChoiceUpdate(customerCareName: customerCareName, patientName: patientName, serviceChoice: serviceChoice))
        addHistory(newHistory)
    }
    
    func logNewPatient(patientName: String) {
        let newHistory = History(type: .newPatient(patientName: patientName))
        addHistory(newHistory)
    }
}
