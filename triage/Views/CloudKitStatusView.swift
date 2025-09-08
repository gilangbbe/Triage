//
//  CloudKitStatusView.swift
//  triage
//
//  Created by Assistant on 08/09/25.
//

import SwiftUI
import CloudKit

struct CloudKitStatusView: View {
    @Environment(CloudKitManager.self) private var cloudKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // CloudKit Status
            HStack {
                Image(systemName: cloudKitManager.isCloudKitEnabled ? "icloud" : "icloud.slash")
                    .foregroundColor(cloudKitManager.isCloudKitEnabled ? .blue : .red)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Sync")
                        .font(.headline)
                    Text(cloudKitManager.isCloudKitEnabled ? "Connected" : "Not Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if cloudKitManager.isCloudKitEnabled {
                    Button(action: {
                        cloudKitManager.triggerSync()
                    }) {
                        HStack {
                            if case .syncing = cloudKitManager.syncStatus {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Sync")
                        }
                    }
                    .disabled(cloudKitManager.syncStatus == .syncing)
                }
            }
            
            // Sync Status
            if cloudKitManager.isCloudKitEnabled {
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(cloudKitManager.getCloudKitStatus())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Help Text
            if !cloudKitManager.isCloudKitEnabled {
                Text("Sign in to iCloud in Settings to sync your data across devices.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statusColor: Color {
        switch cloudKitManager.syncStatus {
        case .idle:
            return .gray
        case .syncing:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}

#Preview {
    NavigationView {
        Form {
            CloudKitStatusView()
        }
    }
    .environment(CloudKitManager.shared)
}
