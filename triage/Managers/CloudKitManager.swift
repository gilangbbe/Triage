//
//  CloudKitManager.swift
//  triage
//
//  Created by Assistant on 08/09/25.
//

import Foundation
import CloudKit
import SwiftData

@Observable
class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private var database: CKDatabase { container.publicCloudDatabase }
    
    var isCloudKitEnabled = true
    var syncStatus: SyncStatus = .idle
    var lastSyncDate: Date?
    
    // Managers for accessing SwiftData
    private var patientManager: PatientManager?
    private var appointmentManager: AppointmentManager?
    private var packageManager: PackageManager?
    private var departmentManager: DepartmentManager?
    private var quickReplyManager: QuickReplyManager?
    private var historyManager: HistoryManager?
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case error(String)
        case success
    }
    
    private init() {
        // Use the specific container for your app
        self.container = CKContainer(identifier: "iCloud.com.ada.triage")
        checkCloudKitAvailability()
    }
    
    // MARK: - Manager Setup
    func setManagers(
        patient: PatientManager,
        appointment: AppointmentManager,
        package: PackageManager,
        department: DepartmentManager,
        quickReply: QuickReplyManager,
        history: HistoryManager
    ) {
        self.patientManager = patient
        self.appointmentManager = appointment
        self.packageManager = package
        self.departmentManager = department
        self.quickReplyManager = quickReply
        self.historyManager = history
    }
    
    // MARK: - CloudKit Availability
    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isCloudKitEnabled = true
                    print("✅ CloudKit is available")
                case .noAccount:
                    self?.isCloudKitEnabled = false
                    print("❌ No iCloud account signed in")
                case .restricted:
                    self?.isCloudKitEnabled = false
                    print("❌ CloudKit access is restricted")
                case .couldNotDetermine:
                    self?.isCloudKitEnabled = false
                    print("❌ Could not determine CloudKit status")
                case .temporarilyUnavailable:
                    self?.isCloudKitEnabled = false
                    print("⚠️ CloudKit is temporarily unavailable")
                @unknown default:
                    self?.isCloudKitEnabled = false
                    print("❌ Unknown CloudKit status")
                }
                
                if let error = error {
                    print("CloudKit status error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Manual Sync Trigger
    func triggerSync() {
        guard isCloudKitEnabled else {
            print("⚠️ CloudKit is not enabled, skipping sync")
            syncStatus = .error("CloudKit not available")
            return
        }
        
        syncStatus = .syncing
        
        // Perform bidirectional sync by triggering individual manager syncs
        Task {
            await performBidirectionalSync()
        }
    }
    
    // MARK: - Bidirectional Sync
    func performBidirectionalSync() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            do {
                print("🔄 Starting bidirectional sync with CloudKit public database...")
                
                // Trigger individual manager sync methods
                await departmentManager?.loadFromCloudKit()
                await packageManager?.loadFromCloudKit()
                await patientManager?.loadFromCloudKit()
                await quickReplyManager?.loadFromCloudKit()
                await appointmentManager?.loadFromCloudKit()
                await historyManager?.loadFromCloudKit()
                
                DispatchQueue.main.async {
                    self.syncStatus = .success
                    self.lastSyncDate = Date()
                    
                    // Reset to idle after showing success briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.syncStatus = .idle
                    }
                }
                
                print("✅ Bidirectional sync completed successfully")
                
            } catch {
                print("❌ CloudKit sync error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.syncStatus = .error(error.localizedDescription)
                    
                    // Reset to idle after showing error briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.syncStatus = .idle
                    }
                }
            }
        }
    }
    
    // MARK: - Download Data from CloudKit
    func downloadDataFromCloudKit() async {
        guard isCloudKitEnabled else { return }
        
        do {
            print("📥 Downloading data from CloudKit public database...")
            
            // Use individual manager download methods in dependency order
            await departmentManager?.loadFromCloudKit()
            await packageManager?.loadFromCloudKit()
            await patientManager?.loadFromCloudKit()
            await quickReplyManager?.loadFromCloudKit()
            await appointmentManager?.loadFromCloudKit()
            await historyManager?.loadFromCloudKit()
            
            print("✅ All data downloaded from CloudKit successfully")
            
        } catch {
            print("❌ CloudKit download error: \(error.localizedDescription)")
        }
    }
    
    func getCloudKitStatus() -> String {
        if !isCloudKitEnabled {
            return "CloudKit Unavailable"
        }
        
        switch syncStatus {
        case .idle:
            if let lastSync = lastSyncDate {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                return "Last sync: \(formatter.string(from: lastSync))"
            } else {
                return "Ready to sync"
            }
        case .syncing:
            return "Syncing..."
        case .error(let message):
            return "Error: \(message)"
        case .success:
            return "Sync completed"
        }
    }
    
    // MARK: - CloudKit Container Configuration
    static func configureCloudKit() {
        print("📱 CloudKit public database configuration completed")
        
        // Initialize the container and check permissions for public database
        let container = CKContainer(identifier: "iCloud.com.ada.triage")
        
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            if let error = error {
                print("❌ CloudKit permission error: \(error.localizedDescription)")
            } else {
                print("✅ CloudKit permissions configured")
            }
        }
    }
    
    // MARK: - Public Database Schema Setup
    func setupPublicDatabaseSchema() {
        // This method would set up the CloudKit schema for public database
        // In production, you would define your record types in CloudKit Dashboard
        print("📊 Setting up CloudKit public database schema")
    }
    
    // MARK: - Utility Methods
    func clearLocalData() {
        // Clear all local managers (useful for testing)
        print("🗑️ Clearing all local data...")
        // Note: This would typically require implementing clear methods in each manager
    }
    
    func getRecordCount() async -> [String: Int] {
        var counts: [String: Int] = [:]
        
        let recordTypes = ["Department", "Package", "Patient", "QuickReply", "Appointment", "History"]
        
        for recordType in recordTypes {
            do {
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                let (matchResults, _) = try await database.records(matching: query, resultsLimit: 1000)
                counts[recordType] = matchResults.count
            } catch {
                print("❌ Failed to count \(recordType): \(error.localizedDescription)")
                counts[recordType] = 0
            }
        }
        
        return counts
    }
    
    // MARK: - Force Upload (overwrite CloudKit with local data)
    func forceUploadAllData() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            // Upload data using individual manager sync methods
            await departmentManager?.syncAllToCloudKit()
            await packageManager?.syncAllToCloudKit()
            await patientManager?.syncAllToCloudKit()
            await quickReplyManager?.syncAllToCloudKit()
            await appointmentManager?.syncAllToCloudKit()
            await historyManager?.syncAllToCloudKit()
            
            DispatchQueue.main.async {
                self.syncStatus = .success
                self.lastSyncDate = Date()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.syncStatus = .idle
                }
            }
        }
    }
    
    // MARK: - Force Download (overwrite local data with CloudKit)
    func forceDownloadAllData() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            // First clear local data (if you implement this functionality)
            // Then download fresh from CloudKit
            await downloadDataFromCloudKit()
            
            DispatchQueue.main.async {
                self.syncStatus = .success
                self.lastSyncDate = Date()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.syncStatus = .idle
                }
            }
        }
    }
}
