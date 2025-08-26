//
//  QuickReply.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import Foundation

struct QuickReply: Identifiable, Codable {
    let id = UUID()
    var title: String
    var message: String
    var isActive: Bool
    var dateCreated: Date
    
    init(title: String, message: String, isActive: Bool = true) {
        self.title = title
        self.message = message
        self.isActive = isActive
        self.dateCreated = Date()
    }
}

// MARK: - Quick Reply Manager
class QuickReplyManager: ObservableObject {
    static let shared = QuickReplyManager()
    
    @Published var quickReplies: [QuickReply] = []
    
    private let userDefaults = UserDefaults.standard
    private let quickRepliesKey = "QuickReplies"
    
    // App Group for sharing data between main app and keyboard extension
    private let appGroupID = "group.com.ada.triage"
    private var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    private init() {
        loadQuickReplies()
        setupDefaultReplies()
    }
    
    // MARK: - CRUD Operations
    func addQuickReply(_ reply: QuickReply) {
        quickReplies.append(reply)
        saveQuickReplies()
    }
    
    func updateQuickReply(_ reply: QuickReply) {
        if let index = quickReplies.firstIndex(where: { $0.id == reply.id }) {
            quickReplies[index] = reply
            saveQuickReplies()
        }
    }
    
    func deleteQuickReply(_ reply: QuickReply) {
        quickReplies.removeAll { $0.id == reply.id }
        saveQuickReplies()
    }
    
    func deleteQuickReply(at indexSet: IndexSet) {
        quickReplies.remove(atOffsets: indexSet)
        saveQuickReplies()
    }
    
    func toggleReplyStatus(_ reply: QuickReply) {
        var updatedReply = reply
        updatedReply.isActive.toggle()
        updateQuickReply(updatedReply)
    }
    
    // MARK: - Persistence
    private func saveQuickReplies() {
        if let encoded = try? JSONEncoder().encode(quickReplies) {
            userDefaults.set(encoded, forKey: quickRepliesKey)
            // Also save to shared container for keyboard extension
            sharedUserDefaults?.set(encoded, forKey: quickRepliesKey)
        }
    }
    
    func loadQuickReplies() {
        // Try to load from shared container first (in case keyboard extension made changes)
        var data: Data?
        
        if let sharedData = sharedUserDefaults?.data(forKey: quickRepliesKey) {
            data = sharedData
        } else if let localData = userDefaults.data(forKey: quickRepliesKey) {
            data = localData
        }
        
        if let data = data,
           let decoded = try? JSONDecoder().decode([QuickReply].self, from: data) {
            quickReplies = decoded
        }
    }
    
    // MARK: - Utilities
    var activeReplies: [QuickReply] {
        return quickReplies.filter { $0.isActive }.sorted { $0.title < $1.title }
    }
    
    private func setupDefaultReplies() {
        // Only add default replies if no replies exist
        guard quickReplies.isEmpty else { return }
        
        let defaultReplies = [
            QuickReply(title: "Thank You", message: "Thank you for your order! We'll process it shortly."),
            QuickReply(title: "Order Confirmed", message: "Your order has been confirmed and is being prepared."),
            QuickReply(title: "Ready for Pickup", message: "Your order is ready for pickup! Please come to our location."),
            QuickReply(title: "Delivery Update", message: "Your order is on the way! Estimated delivery time: 30 minutes."),
            QuickReply(title: "Ask for Details", message: "Could you please provide more details about your order? (Name, address, phone number)"),
            QuickReply(title: "Price Quote", message: "Thank you for your interest! Let me prepare a price quote for you."),
            QuickReply(title: "Working Hours", message: "Our working hours are Monday-Sunday, 9:00 AM - 9:00 PM. How can we help you?")
        ]
        
        quickReplies = defaultReplies
        saveQuickReplies()
    }
}
