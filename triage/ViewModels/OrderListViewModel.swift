//
//  OrderListViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import Combine

class OrderListViewModel: ObservableObject {
    @Published var orders: [CustomerOrder] = []
    @Published var searchText = ""
    @Published var selectedStatus: OrderStatus? = nil
    @Published var showingAddOrder = false
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
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
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.$orders
            .receive(on: DispatchQueue.main)
            .assign(to: \.orders, on: self)
            .store(in: &cancellables)
    }
    
    func deleteOrder(_ order: CustomerOrder) {
        dataManager.deleteOrder(order)
    }
    
    func deleteOrders(at indexSet: IndexSet) {
        let ordersToDelete = indexSet.map { filteredOrders[$0] }
        ordersToDelete.forEach { dataManager.deleteOrder($0) }
    }
    
    func updateOrderStatus(_ order: CustomerOrder, status: OrderStatus) {
        var updatedOrder = order
        updatedOrder.status = status
        dataManager.updateOrder(updatedOrder)
    }
    
    func clearAllFilters() {
        searchText = ""
        selectedStatus = nil
    }
}
