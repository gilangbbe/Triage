//
//  OrderListViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import SwiftUI

@Observable
class OrderListViewModel {
    var searchText = ""
    var selectedStatus: OrderStatus? = nil
    var showingAddOrder = false
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    var orders: [CustomerOrder] {
        return dataManager.orders
    }
    
    var filteredOrders: [CustomerOrder] {
        var result = orders
        
        // Apply status filter
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { order in
                order.name.localizedCaseInsensitiveContains(searchText) ||
                order.email.localizedCaseInsensitiveContains(searchText) ||
                order.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    func deleteOrder(_ order: CustomerOrder) {
        dataManager.deleteOrder(order)
    }
    
    func deleteOrders(at indexSet: IndexSet) {
        let ordersToDelete = indexSet.map { filteredOrders[$0] }
        ordersToDelete.forEach { dataManager.deleteOrder($0) }
    }
    
    func updateOrderStatus(_ order: CustomerOrder, status: OrderStatus) {
        order.status = status
        dataManager.updateOrder(order)
    }
    
    func clearAllFilters() {
        searchText = ""
        selectedStatus = nil
    }
}
