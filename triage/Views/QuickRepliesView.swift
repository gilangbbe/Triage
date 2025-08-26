//
//  QuickRepliesView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

import SwiftUI

struct QuickRepliesView: View {
    @Environment(QuickReplyManager.self) private var replyManager
    @State private var showingAddReply = false
    
    var body: some View {
        NavigationView {
            List {
                if replyManager.quickReplies.isEmpty {
                    EmptyRepliesView()
                } else {
                    ForEach(replyManager.quickReplies) { reply in
                        QuickReplyRowView(reply: reply)
                    }
                    .onDelete(perform: replyManager.deleteQuickReply)
                }
            }
            .navigationTitle("Quick Replies")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReply = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReply) {
                AddQuickReplyView()
            }
        }
    }
}

struct QuickReplyRowView: View {
    let reply: QuickReply
    @Environment(QuickReplyManager.self) private var quickReplyManager
    @State private var showingEditView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reply.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(reply.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { reply.isActive },
                    set: { _ in 
                        quickReplyManager.toggleReplyStatus(reply)
                    }
                ))
                .labelsHidden()
            }
            
            Text(reply.dateCreated.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditView = true
        }
        .sheet(isPresented: $showingEditView) {
            EditQuickReplyView(reply: reply)
        }
    }
}

struct EmptyRepliesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Quick Replies")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create quick replies to speed up your customer service responses.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct AddQuickReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    @State private var title = ""
    @State private var message = ""
    @State private var isActive = true
    
    var isValidReply: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reply Information")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...8)
                        .textInputAutocapitalization(.sentences)
                }
                
                Section {
                    Toggle("Active", isOn: $isActive)
                } footer: {
                    Text("Only active replies will appear in the keyboard extension.")
                }
            }
            .navigationTitle("New Quick Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReply()
                        dismiss()
                    }
                    .disabled(!isValidReply)
                }
            }
        }
    }
    
    private func saveReply() {
        let reply = QuickReply(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: isActive
        )
        quickReplyManager.addQuickReply(reply)
    }
}

#Preview {
    QuickRepliesView()
}
