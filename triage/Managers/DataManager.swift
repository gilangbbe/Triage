//
//  DataManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class DataManager {
    static let shared = DataManager()
    
    var orders: [CustomerOrder] = []
    private var modelContext: ModelContext?
    
    // App Group for sharing data between main app and keyboard extension
    private let appGroupID = "group.com.ada.triage"
    private var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    private init() {
        // ModelContext will be set by the main app
        loadOrders()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadOrders() // Reload data with the new context
    }
    
    // MARK: - CRUD Operations
    func addOrder(_ order: CustomerOrder) {
        guard let context = modelContext else { return }
        
        context.insert(order)
        saveContext()
        loadOrders()
    }
    
    func updateOrder(_ order: CustomerOrder) {
        saveContext()
        loadOrders()
    }
    
    func deleteOrder(_ order: CustomerOrder) {
        guard let context = modelContext else { return }
        
        context.delete(order)
        saveContext()
        loadOrders()
    }
    
    func deleteOrders(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let order = orders[index]
            context.delete(order)
        }
        saveContext()
        loadOrders()
    }
    
    func clearAllOrders() {
        guard let context = modelContext else { return }
        
        for order in orders {
            context.delete(order)
        }
        saveContext()
        loadOrders()
    }
    
    // MARK: - Data Loading
    func loadOrders() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<CustomerOrder>(
                sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
            )
            orders = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch orders: \(error)")
            orders = []
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
    
    // MARK: - Keyboard Extension Integration
    func syncFromKeyboardExtension() {
        // Load any new orders from keyboard extension
        guard let sharedData = sharedUserDefaults?.data(forKey: "NewOrders"),
              let orderDataArray = try? JSONDecoder().decode([CustomerOrderData].self, from: sharedData),
              let context = modelContext else { return }
        
        // Get existing order IDs
        let existingIDs = Set(orders.map { $0.id.uuidString })
        
        // Add new orders from keyboard extension
        for orderData in orderDataArray {
            if !existingIDs.contains(orderData.id) {
                let newOrder = CustomerOrder(
                    name: orderData.name,
                    email: orderData.email,
                    address: orderData.address,
                    phoneNumber: orderData.phoneNumber,
                    orderDetails: orderData.orderDetails
                )
                newOrder.id = UUID(uuidString: orderData.id) ?? UUID()
                newOrder.dateCreated = orderData.dateCreated
                newOrder.status = OrderStatus(rawValue: orderData.status) ?? .pending
                
                context.insert(newOrder)
            }
        }
        
        // Clear the processed orders from shared container
        sharedUserDefaults?.removeObject(forKey: "NewOrders")
        
        saveContext()
        loadOrders()
    }
    
    // MARK: - Search and Filter
    func searchOrders(query: String) -> [CustomerOrder] {
        if query.isEmpty {
            return orders
        }
        
        return orders.filter { order in
            order.name.localizedCaseInsensitiveContains(query) ||
            order.email.localizedCaseInsensitiveContains(query) ||
            order.address.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterOrders(by status: OrderStatus) -> [CustomerOrder] {
        return orders.filter { $0.status == status }
    }
}

// MARK: - Data transfer model for keyboard extension
struct CustomerOrderData: Codable {
    let id: String
    var name: String
    var email: String
    var address: String
    var phoneNumber: String?
    var orderDetails: String?
    var dateCreated: Date
    var status: String
}
