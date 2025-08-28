//
//  EditQuickReplyView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//


import SwiftUI
import SwiftData

struct EditQuickReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    let reply: QuickReply
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var isActive: Bool = true
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quick Reply Details")) {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...10)
                    Toggle("Active", isOn: $isActive)
                }
                
                Section(footer: Text("This quick reply will be available in the keyboard extension when active.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Edit Quick Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveQuickReply()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                             message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            title = reply.title
            message = reply.message
            isActive = reply.isActive
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveQuickReply() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedMessage.isEmpty else {
            alertMessage = "Please fill in all fields."
            showingAlert = true
            return
        }
        
        quickReplyManager.updateQuickReply(reply, title: trimmedTitle, message: trimmedMessage, isActive: isActive)
        dismiss()
    }
}

#Preview {
    EditQuickReplyView(reply: QuickReply(title: "Sample", message: "Sample message", isActive: true))
        .environment(QuickReplyManager.shared)
}
