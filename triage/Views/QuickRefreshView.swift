//
//  QuickRefreshView.swift
//  triage
//
//  Created by GitHub Copilot on 09/09/25.
//

import SwiftUI

struct QuickRefreshView: View {
    @Environment(DataRefreshManager.self) private var refreshManager
    let position: Position
    
    enum Position {
        case topTrailing
        case bottomTrailing
        case center
    }
    
    var body: some View {
        VStack(spacing: 8) {
            RefreshButton(size: 16, showText: true)
            
            if case .refreshing = refreshManager.refreshState {
                Text("Updating...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if let lastRefresh = refreshManager.lastRefreshDate {
                Text(formatRelativeTime(lastRefresh))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

struct RefreshFloatingButton: View {
    @Environment(DataRefreshManager.self) private var refreshManager
    
    var body: some View {
        Button(action: {
            Task {
                await refreshManager.refreshAllData()
            }
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .rotationEffect(.degrees(refreshManager.isRefreshing ? 360 : 0))
                .animation(
                    refreshManager.isRefreshing ? 
                    .linear(duration: 1.0).repeatForever(autoreverses: false) : 
                    .default,
                    value: refreshManager.isRefreshing
                )
        }
        .disabled(refreshManager.isRefreshing)
        .opacity(refreshManager.isRefreshing ? 0.6 : 1.0)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            QuickRefreshView(position: .center)
            RefreshFloatingButton()
        }
    }
    .environment(DataRefreshManager.shared)
}
