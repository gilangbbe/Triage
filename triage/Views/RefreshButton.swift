//
//  RefreshButton.swift
//  triage
//
//  Created by GitHub Copilot on 09/09/25.
//

import SwiftUI

struct RefreshButton: View {
    @Environment(DataRefreshManager.self) private var refreshManager
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 20, showText: Bool = false) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        Button(action: {
            Task {
                await refreshManager.refreshAllData()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: size))
                    .rotationEffect(.degrees(refreshManager.isRefreshing ? 360 : 0))
                    .animation(
                        refreshManager.isRefreshing ? 
                        .linear(duration: 1.0).repeatForever(autoreverses: false) : 
                        .default,
                        value: refreshManager.isRefreshing
                    )
                
                if showText {
                    Text("Refresh")
                        .font(.system(size: size * 0.8))
                }
            }
        }
        .disabled(refreshManager.isRefreshing)
        .opacity(refreshManager.isRefreshing ? 0.6 : 1.0)
    }
}

struct RefreshStatusView: View {
    @Environment(DataRefreshManager.self) private var refreshManager
    
    var body: some View {
        HStack(spacing: 8) {
            switch refreshManager.refreshState {
            case .idle:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(refreshManager.lastRefreshText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            case .refreshing:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Refreshing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Updated successfully")
                    .font(.caption)
                    .foregroundColor(.green)
                
            case .error(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Error: \(message)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        RefreshButton()
        RefreshButton(size: 24, showText: true)
        RefreshStatusView()
    }
    .padding()
    .environment(DataRefreshManager.shared)
}
