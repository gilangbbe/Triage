//
//  CloudKitDebugView.swift
//  triage
//
//  Created by Assistant
//

import SwiftUI
import CloudKit

struct CloudKitDebugView: View {
    let cloudKitManager: CloudKitManager
    @State private var recordCounts: [String: Int] = [:]
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                Section("CloudKit Status") {
                    HStack {
                        Text("Connection")
                        Spacer()
                        if cloudKitManager.isCloudKitEnabled {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Label("Disconnected", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Text("Sync Status")
                        Spacer()
                        syncStatusView
                    }
                    
                    if let lastSync = cloudKitManager.lastSyncDate {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Record Counts") {
                    if recordCounts.isEmpty && !isLoading {
                        Text("Tap 'Refresh Counts' to load")
                            .foregroundColor(.secondary)
                    } else if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading counts...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ForEach(recordCounts.sorted(by: { $0.key < $1.key }), id: \.key) { recordType, count in
                            HStack {
                                Text(recordType)
                                Spacer()
                                Text("\(count)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Sync Actions") {
                    Button(action: {
                        cloudKitManager.performBidirectionalSync()
                    }) {
                        Label("Bidirectional Sync", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button(action: {
                        cloudKitManager.forceUploadAllData()
                    }) {
                        Label("Force Upload All", systemImage: "icloud.and.arrow.up")
                    }
                    
                    Button(action: {
                        cloudKitManager.forceDownloadAllData()
                    }) {
                        Label("Force Download All", systemImage: "icloud.and.arrow.down")
                    }
                }
                
                Section("Debugging") {
                    Button(action: refreshCounts) {
                        Label("Refresh Counts", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        cloudKitManager.clearLocalData()
                    }) {
                        Label("Clear Local Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("CloudKit Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var syncStatusView: some View {
        switch cloudKitManager.syncStatus {
        case .idle:
            Label("Idle", systemImage: "moon.fill")
                .foregroundColor(.secondary)
        case .syncing:
            HStack {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Syncing")
            }
            .foregroundColor(.blue)
        case .success:
            Label("Success", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .error(let message):
            Label("Error", systemImage: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
        }
    }
    
    private func refreshCounts() {
        isLoading = true
        Task {
            let counts = await cloudKitManager.getRecordCount()
            DispatchQueue.main.async {
                self.recordCounts = counts
                self.isLoading = false
            }
        }
    }
}

struct CloudKitDebugView_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitDebugView(cloudKitManager: CloudKitManager.shared)
    }
}
