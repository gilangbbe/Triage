//
//  AnalyticsView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(OrderListViewModel.self) private var orderListViewModel
    
    var ordersByStatus: [StatusCount] {
        let orders = orderListViewModel.orders
        return OrderStatus.allCases.map { status in
            StatusCount(status: status, count: orders.filter { $0.status == status }.count)
        }
    }
    
    var ordersThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return orderListViewModel.orders.filter { $0.dateCreated >= weekAgo }.count
    }
    
    var ordersThisMonth: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return orderListViewModel.orders.filter { $0.dateCreated >= monthAgo }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        SummaryCard(title: "Total Orders", value: "\(orderListViewModel.orders.count)", color: .blue)
                        SummaryCard(title: "This Week", value: "\(ordersThisWeek)", color: .green)
                        SummaryCard(title: "This Month", value: "\(ordersThisMonth)", color: .orange)
                        SummaryCard(title: "Completed", value: "\(ordersByStatus.first(where: { $0.status == .completed })?.count ?? 0)", color: .purple)
                    }
                    
                    // Status Distribution Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Orders by Status")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if #available(iOS 16.0, *) {
                            Chart(ordersByStatus, id: \.status) { data in
                                BarMark(
                                    x: .value("Status", data.status.rawValue),
                                    y: .value("Count", data.count)
                                )
                                .foregroundStyle(colorForStatus(data.status))
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            // Fallback for iOS 15 and earlier
                            VStack(spacing: 8) {
                                ForEach(ordersByStatus, id: \.status) { data in
                                    HStack {
                                        Text(data.status.rawValue)
                                            .font(.body)
                                        Spacer()
                                        Text("\(data.count)")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Orders")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let recentOrders = orderListViewModel.orders
                            .sorted { $0.dateCreated > $1.dateCreated }
                            .prefix(5)
                        
                        if recentOrders.isEmpty {
                            Text("No recent orders")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(recentOrders), id: \.id) { order in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(order.name)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(order.dateCreated.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        StatusBadge(status: order.status)
                                    }
                                    .padding(.horizontal)
                                    
                                    if order.id != recentOrders.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
    
    private func colorForStatus(_ status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

struct StatusCount {
    let status: OrderStatus
    let count: Int
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
        .environment(OrderListViewModel(dataManager: DataManager.shared))
}
