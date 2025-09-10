//
//  AddQuickReplyView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AddQuickReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var isActive: Bool = true
    
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
            .navigationTitle("Add Quick Reply")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveQuickReply()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
        }
    }
    
    private func saveQuickReply() {
        let newReply = QuickReply(
            title: title,
            message: message,
            isActive: isActive
        )
        
        quickReplyManager.addQuickReply(newReply)
        dismiss()
    }
}

#Preview {
    AddQuickReplyView()
        .environment(QuickReplyManager.shared)
}
