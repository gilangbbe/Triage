//
//  OrderRowView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct OrderRowView: View {
    let order: CustomerOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !order.email.isEmpty {
                        Text(order.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            if !order.address.isEmpty {
                Label(order.address, systemImage: "location")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if let phoneNumber = order.phoneNumber, !phoneNumber.isEmpty {
                Label(phoneNumber, systemImage: "phone")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(order.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let orderDetails = order.orderDetails, !orderDetails.isEmpty {
                    Text("Has details")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    
    var backgroundColor: Color {
        switch status {
        case .pending:
            return .orange
        case .processing:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.1))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview {
    OrderRowView(order: CustomerOrder(
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main Street",
        phoneNumber: "+1234567890",
        orderDetails: "Sample order details"
    ))
    .padding()
}
