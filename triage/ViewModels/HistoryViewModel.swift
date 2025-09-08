//
//  HistoryViewModel.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 03/09/25.
//

import Foundation
import SwiftData

@Observable
class HistoryViewModel {
    private let historyManager : HistoryManager
    
    init(historyManager: HistoryManager) {
        self.historyManager = historyManager
    }
    
    var groupedLogs: [(date: String, logs: [History])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        let groups = Dictionary(grouping: historyManager.history) { history in
            formatter.string(from: history.timestamp)
        }
        
        return groups.map { (date, logs) in
            let sortedLogs = logs.sorted { $0.timestamp > $1.timestamp }
            return (date: date, logs: sortedLogs)
        }
        .sorted { $0.date > $1.date }
    }
    
    func addHistory(_ history: History) {
        historyManager.addHistory(history)
    }
}
