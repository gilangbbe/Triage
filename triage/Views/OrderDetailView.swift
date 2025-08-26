//
//  OrderDetailView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct OrderDetailView: View {
    @State var order: CustomerOrder
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(order.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusBadge(status: order.status)
                    }
                    
                    Text("Created \(order.dateCreated.formatted(date: .complete, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Contact Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact Information")
                        .font(.headline)
                    
                    if !order.email.isEmpty {
                        ContactInfoRow(icon: "envelope", title: "Email", value: order.email, action: {
                            openEmail(order.email)
                        })
                    }
                    
                    if let phoneNumber = order.phoneNumber, !phoneNumber.isEmpty {
                        ContactInfoRow(icon: "phone", title: "Phone", value: phoneNumber, action: {
                            callPhoneNumber(phoneNumber)
                        })
                    }
                    
                    if !order.address.isEmpty {
                        ContactInfoRow(icon: "location", title: "Address", value: order.address, action: {
                            openMaps(order.address)
                        })
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Order Details
                if let orderDetails = order.orderDetails, !orderDetails.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Details")
                            .font(.headline)
                        
                        Text(orderDetails)
                            .font(.body)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Status Management
                VStack(alignment: .leading, spacing: 12) {
                    Text("Update Status")
                        .font(.headline)
                    
                    StatusPickerView(selectedStatus: $order.status)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditOrderView(order: $order)
        }
        .onChange(of: order.status) { _, newStatus in
            dataManager.updateOrder(order)
        }
    }
    
    private func openEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func callPhoneNumber(_ phoneNumber: String) {
        let cleanedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel:\(cleanedNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMaps(_ address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusPickerView: View {
    @Binding var selectedStatus: OrderStatus
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(OrderStatus.allCases, id: \.self) { status in
                Button(action: {
                    selectedStatus = status
                }) {
                    HStack {
                        Circle()
                            .fill(selectedStatus == status ? Color.blue : Color.clear)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 12, height: 12)
                        
                        Text(status.rawValue)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(selectedStatus == status ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedStatus == status ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        OrderDetailView(order: CustomerOrder(
            name: "John Doe",
            email: "john@example.com",
            address: "123 Main Street, City, State",
            phoneNumber: "+1234567890",
            orderDetails: "2x Coffee (Large)\n1x Sandwich (Turkey)\n1x Salad"
        ))
        .environment(DataManager.shared)
    }
}
