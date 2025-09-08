//
//  SharedConfiguration.swift
//  TriageKeyboard
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation

struct SharedConfiguration {
    
    // MARK: - App Group Configuration
    static let appGroupID = "group.com.ada.hayyaoe.triage"
    
    // MARK: - Shared Data Keys
    struct SharedDataKeys {
        /// Key for storing new orders from keyboard extension (deprecated)
        static let newOrders = "NewOrders"
        /// Key for storing new patients from keyboard extension
        static let newPatients = "NewPatients"
        /// Key for storing quick replies for keyboard extension
        static let quickReplies = "QuickReplies"
    }
    
    // MARK: - Convenience Accessors
    static var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    /// Gets the App Group container URL
    static var appGroupContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
    
    // MARK: - Validation
    /// Validates that the App Group is properly configured
    static func validateAppGroupAccess() -> Bool {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    }
}
