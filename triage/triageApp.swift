//
//  triageApp.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI
import SwiftData
import CloudKit
import UIKit
import UserNotifications

@main
struct triageApp: App {
    let modelContainer: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    @State var isLoggedIn: User? = UserManager.shared.loadUserProfile()
    
    init() {
        do {
            let configuration = ModelConfiguration(
                schema: Schema([
                    Patient.self,
                    Appointment.self, 
                    Package.self,
                    Department.self,
                    TimeSlot.self,
                    QuickReply.self,
                    History.self
                ]),
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            
            modelContainer = try ModelContainer(
                for: Patient.self, Appointment.self, Package.self, Department.self, TimeSlot.self, QuickReply.self, History.self,
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
            if isLoggedIn != nil {
                ContentView()
                    .modelContainer(modelContainer)
                    .environment(PatientManager.shared)
                    .environment(AppointmentManager.shared)
                    .environment(PackageManager.shared)
                    .environment(QuickReplyManager.shared)
                    .environment(HistoryManager.shared)
                    .environment(DepartmentManager.shared)
                    .environment(CloudKitManager.shared)
                    .environment(DataRefreshManager.shared)
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
                    
                    // Set up CloudKit manager with all the managers
                    CloudKitManager.shared.setManagers(
                        patient: PatientManager.shared,
                        appointment: AppointmentManager.shared,
                        package: PackageManager.shared,
                        department: DepartmentManager.shared,
                        quickReply: QuickReplyManager.shared,
                        history: HistoryManager.shared
                    )
                    
                    // Configure CloudKit
                    CloudKitManager.configureCloudKit()
                    
                    // Download existing data from CloudKit on app launch
                    Task {
                        await CloudKitManager.shared.downloadDataFromCloudKit()
                    }
                        
                        // Check for new data from keyboard extension when app becomes active
                        NotificationCenter.default.addObserver(
                            forName: UIApplication.didBecomeActiveNotification,
                            object: nil,
                            queue: .main
                        ) { _ in
                            PatientManager.shared.syncFromKeyboardExtension()
                            QuickReplyManager.shared.loadQuickReplies()
                        
                        // Also check for new CloudKit data
                        Task {
                            await CloudKitManager.shared.downloadDataFromCloudKit()
                        }
                        }
                    }
                    .onChange(of: scenePhase) { phase in
                        if phase == .active {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }
                    }
            } else {
                SignUpView(user: $isLoggedIn)
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
