//
//  QuickReplyManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import Foundation
import SwiftData

@Observable
class QuickReplyManager {
    static let shared = QuickReplyManager()
    
    var quickReplies: [QuickReply] = []
    private var modelContext: ModelContext?
    
    // App Group for sharing data between main app and keyboard extension
    private let appGroupID = "group.com.ada.triage"
    private var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    private init() {
        // ModelContext will be set by the main app
        loadQuickReplies()
        setupDefaultReplies()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadQuickReplies() // Reload data with the new context
        setupDefaultReplies()
    }
    
    // MARK: - CRUD Operations
    func addQuickReply(_ reply: QuickReply) {
        guard let context = modelContext else { return }
        
        context.insert(reply)
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
    }
    
    func updateQuickReply(_ reply: QuickReply) {
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
    }
    
    func deleteQuickReply(_ reply: QuickReply) {
        guard let context = modelContext else { return }
        
        context.delete(reply)
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
    }
    
    func deleteQuickReply(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let reply = quickReplies[index]
            context.delete(reply)
        }
        saveContext()
        loadQuickReplies()
        syncToSharedContainer()
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
            sharedUserDefaults?.set(encoded, forKey: "QuickReplies")
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
}

// MARK: - Data transfer model for keyboard extension
struct QuickReplyData: Codable {
    let id: String
    var title: String
    var message: String
    var isActive: Bool
    var dateCreated: Date
}
