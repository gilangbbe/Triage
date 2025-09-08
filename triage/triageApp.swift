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

@main
struct triageApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData with CloudKit Public Database
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
                cloudKitDatabase: .automatic
            )
            
            modelContainer = try ModelContainer(
                for: Patient.self, Appointment.self, Package.self, Department.self, TimeSlot.self, QuickReply.self, History.self,
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
                .environment(PatientManager.shared)
                .environment(AppointmentManager.shared)
                .environment(PackageManager.shared)
                .environment(QuickReplyManager.shared)
                .environment(HistoryManager.shared)
                .environment(DepartmentManager.shared)
                .environment(CloudKitManager.shared)
                .onAppear {
                    // Set model context for managers
                    let context = modelContainer.mainContext
                    PatientManager.shared.setModelContext(context)
                    AppointmentManager.shared.setModelContext(context)
                    PackageManager.shared.setModelContext(context)
                    QuickReplyManager.shared.setModelContext(context)
                    HistoryManager.shared.setModelContext(context)
                    DepartmentManager.shared.setModelContext(context)
                    
                    // Configure CloudKit
                    CloudKitManager.configureCloudKit()
                    
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
        }
    }
}
