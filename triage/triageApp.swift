//
//  triageApp.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI
import SwiftData

@main
struct triageApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData to use the App Group container
            let appGroupID = "group.com.ada.triage"
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
                fatalError("Could not find App Group container")
            }
            
            let storeURL = containerURL.appendingPathComponent("TriageData.sqlite")
            let configuration = ModelConfiguration(url: storeURL)
            
            modelContainer = try ModelContainer(
                for: CustomerOrder.self, QuickReply.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(DataManager.shared)
                .environment(QuickReplyManager.shared)
                .onAppear {
                    // Set model context for managers
                    let context = modelContainer.mainContext
                    DataManager.shared.setModelContext(context)
                    QuickReplyManager.shared.setModelContext(context)
                    
                    // Check for new data from keyboard extension when app becomes active
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.didBecomeActiveNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        DataManager.shared.syncFromKeyboardExtension()
                        QuickReplyManager.shared.loadQuickReplies()
                    }
                }
        }
    }
}
