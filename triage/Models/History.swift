//
//  Notification.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 02/09/25.
//

import Foundation
import SwiftData
import CloudKit

@Model
class History: ObservableObject {
    var id: UUID = UUID()
    private var typeData: Data = Data()
    var type: HistoryType {
        get {
            guard !typeData.isEmpty else { return .newPatient(patientName: "") }
            return (try? JSONDecoder().decode(HistoryType.self, from: typeData)) ?? .newPatient(patientName: "")
        }
        set {
            typeData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    var timestamp: Date = Date()
    
    init(id: UUID = UUID(), type: HistoryType, timestamp: Date = Date()) {
        self.id = id
        self.typeData = (try? JSONEncoder().encode(type)) ?? Data()
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
