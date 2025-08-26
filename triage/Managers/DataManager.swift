//
//  DataManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var orders: [CustomerOrder] = []
    
    private let userDefaults = UserDefaults.standard
    private let ordersKey = "SavedOrders"
    
    // App Group for sharing data between main app and keyboard extension
    private let appGroupID = "group.com.ada.triage"
    private var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    private init() {
        loadOrders()
    }
    
    // MARK: - CRUD Operations
    func addOrder(_ order: CustomerOrder) {
        orders.append(order)
        saveOrders()
    }
    
    func updateOrder(_ order: CustomerOrder) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
            saveOrders()
        }
    }
    
    func deleteOrder(_ order: CustomerOrder) {
        orders.removeAll { $0.id == order.id }
        saveOrders()
    }
    
    func deleteOrder(at indexSet: IndexSet) {
        orders.remove(atOffsets: indexSet)
        saveOrders()
    }
    
    // MARK: - Persistence
    private func saveOrders() {
        if let encoded = try? JSONEncoder().encode(orders) {
            userDefaults.set(encoded, forKey: ordersKey)
            // Also save to shared container for keyboard extension
            sharedUserDefaults?.set(encoded, forKey: ordersKey)
        }
    }
    
    func loadOrders() {
        // Try to load from shared container first (in case keyboard extension added data)
        var data: Data?
        
        if let sharedData = sharedUserDefaults?.data(forKey: ordersKey) {
            data = sharedData
        } else if let localData = userDefaults.data(forKey: ordersKey) {
            data = localData
        }
        
        if let data = data,
           let decoded = try? JSONDecoder().decode([CustomerOrder].self, from: data) {
            orders = decoded
        }
    }
    
    // MARK: - Keyboard Extension Methods
    func addOrderFromKeyboard(_ order: CustomerOrder) {
        // This method will be called from the keyboard extension
        var currentOrders = loadOrdersFromShared()
        currentOrders.append(order)
        saveOrdersToShared(currentOrders)
        
        // Update local orders if main app is running
        DispatchQueue.main.async {
            self.orders = currentOrders
        }
    }
    
    private func loadOrdersFromShared() -> [CustomerOrder] {
        guard let data = sharedUserDefaults?.data(forKey: ordersKey),
              let orders = try? JSONDecoder().decode([CustomerOrder].self, from: data) else {
            return []
        }
        return orders
    }
    
    private func saveOrdersToShared(_ orders: [CustomerOrder]) {
        if let encoded = try? JSONEncoder().encode(orders) {
            sharedUserDefaults?.set(encoded, forKey: ordersKey)
        }
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