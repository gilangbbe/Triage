//
//  QuickRepliesView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 26/08/25.
//

//import SwiftUI
//
//struct QuickRepliesView: View {
//    @Environment(QuickReplyManager.self) private var quickReplyManager
//    @State private var showingAddReply = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                if quickReplyManager.quickReplies.isEmpty {
//                    EmptyRepliesView()
//                } else {
//                    ForEach(quickReplyManager.quickReplies) { reply in
//                        QuickReplyRowView(reply: reply)
//                    }
//                    .onDelete { indexSet in
//                        quickReplyManager.deleteQuickReply(at: indexSet)
//                    }
//                }
//            }
//            .navigationTitle("Quick Replies")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showingAddReply = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $showingAddReply) {
//                AddQuickReplyView()
//            }
//        }
//    }
//}
//
//struct QuickReplyRowView: View {
//    let reply: QuickReply
//    @Environment(QuickReplyManager.self) private var quickReplyManager
//    @State private var showingEditView = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(reply.title)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    Text(reply.message)
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                }
//                
//                Spacer()
//                
//                Toggle("", isOn: Binding(
//                    get: { reply.isActive },
//                    set: { _ in 
//                        quickReplyManager.toggleReplyStatus(reply)
//                    }
//                ))
//                .labelsHidden()
//            }
//            
//            Text(reply.dateCreated.formatted(date: .abbreviated, time: .shortened))
//                .font(.caption)
//                .foregroundColor(.primary)
//        }
//        .padding(.vertical, 4)
//        .contentShape(Rectangle())
//        .onTapGesture {
//            showingEditView = true
//        }
//        .sheet(isPresented: $showingEditView) {
//            EditQuickReplyView(reply: reply)
//        }
//    }
//}
//
//struct EmptyRepliesView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "bubble.left.and.bubble.right")
//                .font(.system(size: 60))
//                .foregroundColor(.secondary)
//            
//            VStack(spacing: 8) {
//                Text("No Quick Replies")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                
//                Text("Create quick replies to speed up your customer service responses.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .listRowBackground(Color.clear)
//        .listRowSeparator(.hidden)
//    }
//}
//
//#Preview {
//    QuickRepliesView()
//        .environment(QuickReplyManager.shared)
//}
