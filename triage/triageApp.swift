//
//  triageApp.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI
import SwiftData
import UIKit
import UserNotifications

@main
struct triageApp: App {
    let modelContainer: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        do {
            // Configure SwiftData to use the App Group container
            guard let storeURL = AppConfiguration.swiftDataStoreURL else {
                fatalError("Could not find App Group container: \(AppConfiguration.appGroupID)")
            }
            
            let configuration = ModelConfiguration(url: storeURL)
            
            modelContainer = try ModelContainer(
                for: Patient.self, Appointment.self, Package.self, QuickReply.self, History.self,
                configurations: configuration
            )
            
            let center = UNUserNotificationCenter.current()
            center.delegate = NotificationDelegate.shared
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Granted: \(granted)")
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(PatientManager.shared)
                .environment(AppointmentManager.shared)
                .environment(PackageManager.shared)
                .environment(QuickReplyManager.shared)
                .environment(HistoryManager.shared)
                .environment(DepartmentManager.shared)
                .environment(NotificationManager.shared)
                .onAppear {
                    // Set model context for managers
                    let context = modelContainer.mainContext
                    PatientManager.shared.setModelContext(context)
                    AppointmentManager.shared.setModelContext(context)
                    PackageManager.shared.setModelContext(context)
                    QuickReplyManager.shared.setModelContext(context)
                    HistoryManager.shared.setModelContext(context)
                    DepartmentManager.shared.setModelContext(context)
                    
                    // Check for new data from keyboard extension when app becomes active
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.didBecomeActiveNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        PatientManager.shared.syncFromKeyboardExtension()
                        QuickReplyManager.shared.loadQuickReplies()
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission Granted")
            } else {
                print("Permission Denied")
            }
        }
    }
}
