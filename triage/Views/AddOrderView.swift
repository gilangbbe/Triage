//
//  AddOrderView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct AddOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddOrderViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Information")) {
                    TextField("Name *", text: $viewModel.name)
                        .textContentType(.name)
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $viewModel.phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address", text: $viewModel.address, axis: .vertical)
                        .textContentType(.fullStreetAddress)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Order Details")) {
                    TextField("Order details (optional)", text: $viewModel.orderDetails, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section {
                    Button("Parse from Text") {
                        viewModel.showingRawTextInput = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("New Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveOrder()
                        dismiss()
                    }
                    .disabled(!viewModel.isValidOrder)
                }
            }
            .sheet(isPresented: $viewModel.showingRawTextInput) {
                RawTextInputView(viewModel: viewModel)
            }
        }
    }
}

struct RawTextInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddOrderViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Paste customer message here:")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text("Example format:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("name: John Doe")
                    Text("email: john@example.com")
                    Text("address: 123 Main Street")
                    Text("phone: +1234567890")
                    Text("order: 2x Coffee, 1x Sandwich")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                TextEditor(text: $viewModel.rawText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Parse Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Parse") {
                        viewModel.parseFromRawText()
                        dismiss()
                    }
                    .disabled(viewModel.rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddOrderView()
}
