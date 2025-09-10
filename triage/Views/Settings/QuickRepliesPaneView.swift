//
//
//  QuickRepliesPaneView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

// MARK: - Quick Replies
struct QuickRepliesPaneView: View {
    @Environment(QuickReplyManager.self) private var quickReplyManager
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var editingReply: QuickReply? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search + Add
            HStack(spacing: 12) {
                Text("Setting Up the Quick Replies")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(hex: "#0F0E46"))
                Spacer()
                SearchField(text: $searchText, placeholder: "Search")
                    .frame(width: 200)
                Button {
                    showingAddSheet = true
                } label: {
                    Text("Add")
                        .font(.footnote)
                        .foregroundStyle(Color(hex: "#0F0E46"))
                }
            }

            // List
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredItems) { item in
                        QuickReplyCard(item: item, onToggle: toggle, onTap: edit)
                    }
                }
                .padding(4)
            }
        }
        .padding([.top, .leading, .trailing], 16)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingAddSheet) { AddQuickReplyView() }
        .sheet(item: $editingReply) { reply in EditQuickReplyView(reply: reply) }
    }
    
    // MARK: - Helpers
    private var filteredItems: [QuickReply] {
        guard !searchText.isEmpty else { return quickReplyManager.quickReplies }
        let q = searchText.lowercased()
        return quickReplyManager.quickReplies.filter {
            $0.title.lowercased().contains(q) || $0.message.lowercased().contains(q)
        }
    }
    private func toggle(_ item: QuickReply) { quickReplyManager.toggleReplyStatus(item) }
    private func edit(_ item: QuickReply) { editingReply = item }
}

// MARK: - Card
private struct QuickReplyCard: View {
    let item: QuickReply
    var onToggle: (QuickReply) -> Void
    var onTap: (QuickReply) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Checkbox(isOn: item.isActive) { onToggle(item) }
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color(hex: "#0F0E46"))
                Spacer()
            }
            Text(item.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: "E2E2E9"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "0F0E46"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .onTapGesture { onTap(item) }
    }
}


// MARK: - Checkbox
private struct Checkbox: View {
    var isOn: Bool
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(Color(hex: "#0F0E46"))
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Edit View
struct EditQuickReplyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    let reply: QuickReply
    
    @State private var title: String
    @State private var message: String
    @State private var isActive: Bool
    @State private var showingDeleteAlert = false
    
    init(reply: QuickReply) {
        self.reply = reply
        _title = State(initialValue: reply.title)
        _message = State(initialValue: reply.message)
        _isActive = State(initialValue: reply.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Quick Reply Details") {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...10)
                    Toggle("Active", isOn: $isActive)
                }
                
                Section {
                    Button("Delete Quick Reply", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Quick Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
            .alert("Delete Quick Reply", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    quickReplyManager.deleteQuickReply(reply)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete '\(reply.title)'? This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        quickReplyManager.updateQuickReply(reply, title: title, message: message, isActive: isActive)
        dismiss()
    }
}


// MARK: - Preview
#Preview {
    QuickRepliesPaneView()
        .environment(QuickReplyManager.shared)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
}
