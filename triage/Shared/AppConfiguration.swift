//
//  AppConfiguration.swift
//  triage
//
//  Created by Developer on 28/08/25.
//

import Foundation

struct AppConfiguration {
    
    // MARK: - App Group Configuration
    static let appGroupID = "group.com.chiquitta.triage"
    
    // MARK: - Shared Data Keys
    struct SharedDataKeys {
        /// Key for storing new orders from keyboard extension
        static let newOrders = "NewOrders"
        /// Key for storing quick replies for keyboard extension
        static let quickReplies = "QuickReplies"
    }
    
    // MARK: - SwiftData Configuration
    static let swiftDataFileName = "TriageData.sqlite"
    
    // MARK: - App Information
    static let appVersion = "1.0.0"
    
    static let appName = "Triage Customer Care"
    
    // MARK: - Validation
    static func validateAppGroupAccess() -> Bool {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    }
    
    /// Gets the shared UserDefaults instance
    static var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    /// Gets the App Group container URL
    static var appGroupContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
    
    /// Gets the SwiftData store URL in the shared container
    static var swiftDataStoreURL: URL? {
        return appGroupContainerURL?.appendingPathComponent(swiftDataFileName)
    }
}
