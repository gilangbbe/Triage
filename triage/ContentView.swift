//
//  ContentView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(PatientManager.self) private var patientManager
    @Environment(AppointmentManager.self) private var appointmentManager
    @Environment(PackageManager.self) private var packageManager
    @Environment(QuickReplyManager.self) private var quickReplyManager
    
    @State private var patientListViewModel: PatientListViewModel?
    @State private var appointmentListViewModel: AppointmentListViewModel?
    @State private var packageListViewModel: PackageListViewModel?
    
    var body: some View {
        TabView {
            if let patientListViewModel = patientListViewModel {
                PatientListView()
                    .environment(patientListViewModel)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Patients")
                    }
            }
            
            if let appointmentListViewModel = appointmentListViewModel {
                AppointmentListView()
                    .environment(appointmentListViewModel)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Appointments")
                    }
            }
            
            if let packageListViewModel = packageListViewModel {
                PackageListView()
                    .environment(packageListViewModel)
                    .tabItem {
                        Image(systemName: "square.stack.3d.up")
                        Text("Packages")
                    }
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear {
            if patientListViewModel == nil {
                patientListViewModel = PatientListViewModel(patientManager: patientManager)
            }
            if appointmentListViewModel == nil {
                appointmentListViewModel = AppointmentListViewModel(appointmentManager: appointmentManager)
            }
            if packageListViewModel == nil {
                packageListViewModel = PackageListViewModel(packageManager: packageManager)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(PatientManager.shared)
        .environment(AppointmentManager.shared)
        .environment(PackageManager.shared)
        .environment(QuickReplyManager.shared)
}
