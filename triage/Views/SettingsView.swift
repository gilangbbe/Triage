//
//  SettingsView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showingClearAllAlert = false
    @State private var showingKeyboardInstructions = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Keyboard Extension") {
                    Button("Setup Instructions") {
                        showingKeyboardInstructions = true
                    }
                    .foregroundColor(.blue)
                    
                    NavigationLink("Quick Replies") {
                        QuickRepliesView()
                    }
                    
                    NavigationLink("Test Parsing") {
                        TestParsingView()
                    }
                }
                
                Section("Data Management") {
                    Button("Export Data") {
                        exportData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Orders") {
                        showingClearAllAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App Group ID")
                        Spacer()
                        Text("group.com.ada.triage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Clear All Orders", isPresented: $showingClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllOrders()
            }
        } message: {
            Text("This action cannot be undone. All customer orders will be permanently deleted.")
        }
        .sheet(isPresented: $showingKeyboardInstructions) {
            KeyboardInstructionsView()
        }
    }
    
    private func exportData() {
        let orders = DataManager.shared.orders
        guard let data = try? JSONEncoder().encode(orders),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [jsonString], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func clearAllOrders() {
        DataManager.shared.orders.removeAll()
    }
}

struct KeyboardInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Setting Up the Keyboard Extension")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionStep(number: 1, title: "Enable the Keyboard", description: "Go to Settings > General > Keyboard > Keyboards > Add New Keyboard and select 'Triage Parser'")
                        
                        InstructionStep(number: 2, title: "Allow Full Access", description: "In the keyboard settings, enable 'Allow Full Access' for the Triage Parser keyboard")
                        
                        InstructionStep(number: 3, title: "Using the Extension", description: "When typing in any app, switch to the Triage Parser keyboard and paste customer messages to parse them automatically")
                    }
                    
                    Text("Supported Format:")
                        .font(.headline)
                        .padding(.top)
                    
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
                    
                    Text("The parser is flexible and will work with variations like 'nama', 'alamat', 'hp', etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
            }
            .navigationTitle("Keyboard Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TestParsingView: View {
    @State private var testText = """
    name: John Doe
    email: john@example.com
    address: 123 Main Street, Anytown, ST 12345
    phone: +1 (555) 123-4567
    order: 2x Large Coffee, 1x Turkey Sandwich, 1x Caesar Salad
    """
    @State private var parsedOrder: CustomerOrder?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Test the parsing functionality by entering sample text:")
                .font(.headline)
            
            TextEditor(text: $testText)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button("Parse Text") {
                parsedOrder = CustomerOrder.parseFromText(testText)
            }
            .buttonStyle(.borderedProminent)
            
            if let order = parsedOrder {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parsed Result:")
                        .font(.headline)
                    
                    Text("Name: \(order.name)")
                    Text("Email: \(order.email)")
                    Text("Address: \(order.address)")
                    if let phone = order.phoneNumber {
                        Text("Phone: \(phone)")
                    }
                    if let details = order.orderDetails {
                        Text("Order: \(details)")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Test Parsing")
    }
}

#Preview {
    SettingsView()
}
