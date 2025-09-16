//
//  QuickReplyManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import Foundation
import SwiftData
import CloudKit

@Observable
class QuickReplyManager: CloudKitSyncable {
    typealias ModelType = QuickReply
    
    static let shared = QuickReplyManager()
    
    var quickReplies: [QuickReply] = []
    private var modelContext: ModelContext?
    private let cloudKitHelper = CloudKitHelper.shared
    
    // App Group for sharing data between main app and keyboard extension
    private var sharedUserDefaults: UserDefaults? {
        return AppConfiguration.sharedUserDefaults
    }
    
    private init() {
        // ModelContext will be set by the main app
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadQuickReplies() // Load any additional local data
        }
    }
    
    // MARK: - CRUD Operations
    func addQuickReply(_ reply: QuickReply) {
        guard let context = modelContext else { return }
        
        context.insert(reply)
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(reply)
        }
    }
    
    func updateQuickReply(_ reply: QuickReply) {
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(reply)
        }
    }
    
    func deleteQuickReply(_ reply: QuickReply) {
        guard let context = modelContext else { return }
        
        context.delete(reply)
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
        
        // Delete from CloudKit
        Task {
            await deleteFromCloudKit(reply)
        }
    }
    
    func deleteQuickReply(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        var repliesToDelete: [QuickReply] = []
        for index in indexSet {
            let reply = quickReplies[index]
            repliesToDelete.append(reply)
            context.delete(reply)
        }
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
        
        // Delete from CloudKit
        Task {
            for reply in repliesToDelete {
                await deleteFromCloudKit(reply)
            }
        }
    }
    
    func toggleReplyStatus(_ reply: QuickReply) {
        reply.isActive.toggle()
        updateQuickReply(reply)
    }
    
    func updateQuickReply(_ reply: QuickReply, title: String, message: String, isActive: Bool) {
        reply.title = title
        reply.message = message
        reply.isActive = isActive
        updateQuickReply(reply)
    }
    
    // MARK: - Data Loading
    func loadQuickReplies() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<QuickReply>(
                sortBy: [SortDescriptor(\.title, order: .forward)]
            )
            quickReplies = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch quick replies: \(error)")
            quickReplies = []
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save quick replies context: \(error)")
        }
    }
    
    // MARK: - Keyboard Extension Integration
    private func syncToSharedContainer() {
        // Convert SwiftData models to simple data structures for keyboard extension
        let replyData = quickReplies.map { reply in
            QuickReplyData(
                id: reply.id.uuidString,
                title: reply.title,
                message: reply.message,
                isActive: reply.isActive,
                dateCreated: reply.dateCreated
            )
        }
        
        if let encoded = try? JSONEncoder().encode(replyData) {
            sharedUserDefaults?.set(encoded, forKey: AppConfiguration.SharedDataKeys.quickReplies)
        }
    }
    
    // MARK: - Utilities
    var activeReplies: [QuickReply] {
        return quickReplies.filter { $0.isActive }.sorted { $0.title < $1.title }
    }
    
    private func setupDefaultReplies() {
        // Only add default replies if no replies exist
        guard quickReplies.isEmpty, let context = modelContext else { return }
        
        let defaultReplies = [
            QuickReply(title: "Thank You", message: "Thank you for your order! We'll process it shortly."),
            QuickReply(title: "Order Confirmed", message: "Your order has been confirmed and is being prepared."),
            QuickReply(title: "Ready for Pickup", message: "Your order is ready for pickup! Please come to our location."),
            QuickReply(title: "Delivery Update", message: "Your order is on the way! Estimated delivery time: 30 minutes."),
            QuickReply(title: "Ask for Details", message: "Could you please provide more details about your order? (Name, address, phone number)"),
            QuickReply(title: "Price Quote", message: "Thank you for your interest! Let me prepare a price quote for you."),
            QuickReply(title: "Working Hours", message: "Our working hours are Monday-Sunday, 9:00 AM - 9:00 PM. How can we help you?")
        ]
        
        for reply in defaultReplies {
            context.insert(reply)
        }
        
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
    }
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: QuickReply) async {
        let record = CKRecord(recordType: "QuickReply", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["title"] = item.title
        record["message"] = item.message
        record["isActive"] = item.isActive
        record["dateCreated"] = item.dateCreated
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync quick reply to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: QuickReply) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: QuickReply.self)
        } catch {
            print("❌ Failed to delete quick reply from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            // First, get all CloudKit record IDs to identify what should exist
            let cloudKitRecordIDs = try await cloudKitHelper.fetchRecordIDs(ofType: "QuickReply")
            
            // Get current local quick replies and clean up those not in CloudKit
            await MainActor.run {
                guard let context = modelContext else { return }
                
                // Get all local quick replies
                let descriptor = FetchDescriptor<QuickReply>()
                do {
                    let localQuickReplies = try context.fetch(descriptor)
                    
                    // Find local quick replies that no longer exist in CloudKit
                    let localQuickRepliesToDelete = localQuickReplies.filter { quickReply in
                        !cloudKitRecordIDs.contains(quickReply.id.uuidString)
                    }
                    
                    // Delete local quick replies that don't exist in CloudKit
                    for quickReply in localQuickRepliesToDelete {
                        print("🗑️ Deleting local quick reply not found in CloudKit: \(quickReply.title)")
                        context.delete(quickReply)
                    }
                    
                    if !localQuickRepliesToDelete.isEmpty {
                        try context.save()
                    }
                } catch {
                    print("❌ Failed to cleanup local quick replies: \(error)")
                }
            }
            
            // Now fetch and process records from CloudKit
            let records = try await cloudKitHelper.fetchRecords(ofType: "QuickReply")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if quick reply already exists in SwiftData database
                        let quickReplyId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        
                        // Query SwiftData directly to check for existing record
                        guard let context = modelContext else { continue }
                        
                        let descriptor = FetchDescriptor<QuickReply>(
                            predicate: #Predicate<QuickReply> { quickReply in
                                quickReply.id == quickReplyId
                            }
                        )
                        
                        do {
                            let existingQuickReplies = try context.fetch(descriptor)
                            if existingQuickReplies.isEmpty {
                                // Only create if doesn't exist in database
                                let quickReply = QuickReply(
                                    title: record["title"] as? String ?? "",
                                    message: record["message"] as? String ?? "",
                                    isActive: record["isActive"] as? Bool ?? true
                                )
                                quickReply.id = quickReplyId
                                quickReply.dateCreated = record["dateCreated"] as? Date ?? Date()
                                
                                context.insert(quickReply)
                                try context.save()
                                print("✅ Added new quick reply from CloudKit: \(quickReply.title)")
                            } else {
                                // Update existing quick reply with CloudKit data
                                let existingQuickReply = existingQuickReplies[0]
                                existingQuickReply.title = record["title"] as? String ?? existingQuickReply.title
                                existingQuickReply.message = record["message"] as? String ?? existingQuickReply.message
                                existingQuickReply.isActive = record["isActive"] as? Bool ?? existingQuickReply.isActive
                                
                                try context.save()
                                print("🔄 Updated existing quick reply from CloudKit: \(existingQuickReply.title)")
                            }
                        } catch {
                            print("❌ Failed to check/save quick reply from CloudKit: \(error)")
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download quick reply: \(error.localizedDescription)")
                    }
                }
                loadQuickReplies() // Refresh the quick replies array
                syncToSharedContainer() // Update shared container for keyboard extension
            }
        } catch {
            print("❌ Failed to load quick replies from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for quickReply in quickReplies {
            await syncToCloudKit(quickReply)
        }
    }
}

// MARK: - Data transfer model for keyboard extension
struct QuickReplyData: Codable {
    let id: String
    var title: String
    var message: String
    var isActive: Bool
    var dateCreated: Date
}
