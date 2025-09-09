//
//  DataRefreshManager.swift
//  triage
//
//  Created by GitHub Copilot on 09/09/25.
//

import Foundation
import SwiftUI

@Observable
class DataRefreshManager {
    static let shared = DataRefreshManager()
    
    enum RefreshState: Equatable {
        case idle
        case refreshing
        case success
        case error(String)
        
        static func == (lhs: RefreshState, rhs: RefreshState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.refreshing, .refreshing), (.success, .success):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    var refreshState: RefreshState = .idle
    var lastRefreshDate: Date?
    
    // Auto refresh settings
    private let autoRefreshInterval: TimeInterval = 300 // 5 minutes
    private var autoRefreshTimer: Timer?
    
    private init() {
        setupAutoRefresh()
    }
    
    deinit {
        autoRefreshTimer?.invalidate()
    }
    
    // MARK: - Manual Refresh
    @MainActor
    func refreshAllData() async {
        guard refreshState != .refreshing else { return }
        
        refreshState = .refreshing
        
        do {
            print("🔄 Starting data refresh...")
            
            // Refresh all managers in parallel for better performance
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await PatientManager.shared.loadFromCloudKit() }
                group.addTask { await AppointmentManager.shared.loadFromCloudKit() }
                group.addTask { await PackageManager.shared.loadFromCloudKit() }
                group.addTask { await DepartmentManager.shared.loadFromCloudKit() }
                group.addTask { await HistoryManager.shared.loadFromCloudKit() }
                group.addTask { await QuickReplyManager.shared.loadFromCloudKit() }
            }
            
            // Reload local data after CloudKit sync
            PatientManager.shared.loadPatients()
            AppointmentManager.shared.loadAppointments()
            PackageManager.shared.loadPackages()
            DepartmentManager.shared.loadDepartments()
            HistoryManager.shared.loadHistory()
            QuickReplyManager.shared.loadQuickReplies()
            
            refreshState = .success
            lastRefreshDate = Date()
            
            print("✅ Data refresh completed successfully")
            
            // Reset to idle after showing success briefly
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                refreshState = .idle
            } catch {
                // Handle sleep cancellation gracefully
                refreshState = .idle
            }
            
        } catch {
            print("❌ Data refresh failed: \(error.localizedDescription)")
            refreshState = .error(error.localizedDescription)
            
            // Reset to idle after showing error
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                refreshState = .idle
            } catch {
                // Handle sleep cancellation gracefully
                refreshState = .idle
            }
        }
    }
    
    // MARK: - Auto Refresh
    private func setupAutoRefresh() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshAllData()
            }
        }
    }
    
    func enableAutoRefresh() {
        guard autoRefreshTimer == nil else { return }
        setupAutoRefresh()
    }
    
    func disableAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
    
    // MARK: - Utilities
    var isRefreshing: Bool {
        if case .refreshing = refreshState {
            return true
        }
        return false
    }
    
    var lastRefreshText: String {
        guard let lastRefreshDate = lastRefreshDate else {
            return "Never refreshed"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last updated \(formatter.localizedString(for: lastRefreshDate, relativeTo: Date()))"
    }
}
