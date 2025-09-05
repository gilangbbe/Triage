//
//
//  QuickRepliesPaneView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

// MARK: - Right Pane
struct QuickRepliesPaneView: View {
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var editingReply: QuickReply? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Quick Replies Keyboard Setting")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(hex: "#0F0E46"))

            // Search + Add
            HStack(spacing: 12) {
                SearchField("Search", text: $searchText)
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    Text("Add")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#0F0E46"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }

            // Cards
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredItems) { item in
                        QuickReplyCard(
                            item: item,
                            onToggle: toggle,
                            onTap: edit
                        )
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(24)
        .sheet(isPresented: $showingAddSheet) {
            AddQuickReplyView()
        }
        .sheet(item: $editingReply) { reply in
            EditQuickReplyView(reply: reply)
        }
    }

    // MARK: - Helpers
    private var filteredItems: [QuickReply] {
        guard !searchText.isEmpty else { return quickReplyManager.quickReplies }
        let q = searchText.lowercased()
        return quickReplyManager.quickReplies.filter { 
            $0.title.lowercased().contains(q) || $0.message.lowercased().contains(q) 
        }
    }

    private func toggle(_ item: QuickReply) {
        quickReplyManager.toggleReplyStatus(item)
    }

    private func edit(_ item: QuickReply) {
        editingReply = item
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
                    .font(.headline)
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
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
        .onTapGesture { onTap(item) }
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}

// MARK: - UI Bits
private struct SearchField: View {
    var title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .imageScale(.medium)
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct Checkbox: View {
    var isOn: Bool
    var action: () -> Void

    init(isOn: Bool, action: @escaping () -> Void) {
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color(hex: "#0F0E46"))
                .font(.title3)
                .accessibilityLabel(isOn ? "Enabled" : "Disabled")
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    QuickRepliesPaneView()
        .environment(QuickReplyManager.shared)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
}
