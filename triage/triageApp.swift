//
//  triageApp.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

@main
struct triageApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    // Check for new orders from keyboard extension when app becomes active
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.didBecomeActiveNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        dataManager.syncWithKeyboardExtension()
                    }
                }
        }
    }
}

// Extension to handle keyboard extension data sync
extension DataManager {
    func syncWithKeyboardExtension() {
        // Load any new orders that might have been added by the keyboard extension
        loadOrders()
    }
}
