//
//  EditOrderView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct EditOrderView: View {
    @Binding var order: CustomerOrder
    @Environment(\.dismiss) private var dismiss
    @Environment(DataManager.self) private var dataManager
    
    @State private var name: String
    @State private var email: String
    @State private var address: String
    @State private var phoneNumber: String
    @State private var orderDetails: String
    @State private var status: OrderStatus
    
    init(order: Binding<CustomerOrder>) {
        self._order = order
        self._name = State(initialValue: order.wrappedValue.name)
        self._email = State(initialValue: order.wrappedValue.email)
        self._address = State(initialValue: order.wrappedValue.address)
        self._phoneNumber = State(initialValue: order.wrappedValue.phoneNumber ?? "")
        self._orderDetails = State(initialValue: order.wrappedValue.orderDetails ?? "")
        self._status = State(initialValue: order.wrappedValue.status)
    }
    
    var isValidOrder: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
         !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Information")) {
                    TextField("Name *", text: $name)
                        .textContentType(.name)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address", text: $address, axis: .vertical)
                        .textContentType(.fullStreetAddress)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Order Details")) {
                    TextField("Order details", text: $orderDetails, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(OrderStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Edit Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(!isValidOrder)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedOrder = order
        updatedOrder.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedOrder.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedOrder.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedOrder.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedOrder.orderDetails = orderDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : orderDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedOrder.status = status
        
        order = updatedOrder
        dataManager.updateOrder(updatedOrder)
    }
}

#Preview {
    EditOrderView(order: .constant(CustomerOrder(
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main Street",
        phoneNumber: "+1234567890",
        orderDetails: "Sample order"
    )))
    .environment(DataManager.shared)
}
