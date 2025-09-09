//
//  HistoryManager.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 03/09/25.
//

import Foundation
import Combine
import SwiftData
import CloudKit

@Observable
class HistoryManager: CloudKitSyncable {
    typealias ModelType = History
    
    static let shared = HistoryManager()
    
    var history: [History] = []
    private var modelContext: ModelContext?
    private let cloudKitHelper = CloudKitHelper.shared
    
    private init() {
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadHistory() // Load any additional local data
        }
    }
    
    // MARK: - CRUD Operations
    func addHistory(_ historyLog: History) {
        guard let context = modelContext else { return }
        
        context.insert(historyLog)
        saveContext()
        loadHistory()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(historyLog)
        }
    }
    
    func updateHistory(_ historyLog: History) {
        saveContext()
        loadHistory()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(historyLog)
        }
    }
    
    func deleteHistory(_ history: History) {
        guard let context = modelContext else { return }
        
        context.delete(history)
        saveContext()
        loadHistory()
        
        // Delete from CloudKit
        Task {
            await deleteFromCloudKit(history)
        }
    }
    
    func deleteHistoryLog(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        var historyLogsToDelete: [History] = []
        for index in indexSet {
            let historyLog = history[index]
            historyLogsToDelete.append(historyLog)
            context.delete(historyLog)
        }
        saveContext()
        loadHistory()
        
        // Delete from CloudKit
        Task {
            for historyLog in historyLogsToDelete {
                await deleteFromCloudKit(historyLog)
            }
        }
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
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: History) async {
        let record = CKRecord(recordType: "History", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["timestamp"] = item.timestamp
        
        // Encode the history type data
        if let typeData = try? JSONEncoder().encode(item.type),
           let typeString = String(data: typeData, encoding: .utf8) {
            record["typeData"] = typeString
        }
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync history to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: History) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: History.self)
        } catch {
            print("❌ Failed to delete history from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            let records = try await cloudKitHelper.fetchRecords(ofType: "History")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if history already exists locally
                        let historyId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        if !history.contains(where: { $0.id == historyId }) {
                            let timestamp = record["timestamp"] as? Date ?? Date()
                            
                            // Decode history type
                            var historyType: HistoryType = .newPatient(patientName: "Unknown")
                            if let typeString = record["typeData"] as? String,
                               let typeData = typeString.data(using: .utf8),
                               let decodedType = try? JSONDecoder().decode(HistoryType.self, from: typeData) {
                                historyType = decodedType
                            }
                            
                            let historyItem = History(
                                id: historyId,
                                type: historyType,
                                timestamp: timestamp
                            )
                            
                            // Add to local storage
                            if let context = modelContext {
                                context.insert(historyItem)
                                do {
                                    try context.save()
                                } catch {
                                    print("❌ Failed to save history from CloudKit: \(error)")
                                }
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download history: \(error.localizedDescription)")
                    }
                }
                loadHistory() // Refresh the history array
            }
        } catch {
            print("❌ Failed to load history from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for historyItem in history {
            await syncToCloudKit(historyItem)
        }
    }
}