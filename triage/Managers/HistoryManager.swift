//
//  HistoryManager.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 03/09/25.
//

import Foundation
import Combine
import SwiftData

@Observable
class HistoryManager {
    static let shared = HistoryManager()
    
    var history: [History] = []
    private var modelContext: ModelContext?
    
    private init() {
        loadHistory()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadHistory()
    }
    
    // MARK: - CRUD Operations
    func addHistory(_ historyLog: History) {
        guard let context = modelContext else { return }
        
        context.insert(historyLog)
        saveContext()
        loadHistory()
    }
    
    func updateHistory(_ historyLog: History) {
        saveContext()
        loadHistory()
    }
    
    func deleteHistory(_ history: History) {
        guard let context = modelContext else { return }
        
        context.delete(history)
        saveContext()
        loadHistory()
    }
    
    func deleteHistoryLog(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let historyLog = history[index]
            context.delete(historyLog)
        }
        saveContext()
        loadHistory()
    }
    
    // MARK: - Data Loading
    func loadHistory() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<History>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            history = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch packages: \(error)")
            history = []
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
}
