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
    @Environment(HistoryManager.self) private var historyManager
    @Environment(DepartmentManager.self) private var departmentManager
    @Environment(CloudKitManager.self) private var cloudKitManager
    @Environment(DataRefreshManager.self) private var refreshManager
    
    @State private var patientListViewModel: PatientListViewModel?
    @State private var appointmentListViewModel: AppointmentListViewModel?
    @State private var packageListViewModel: PackageListViewModel?
    @State private var historyViewModel: HistoryViewModel?
    @State private var calendarViewModel: CalendarViewModel?
    
    var body: some View {
        TabView {
            if let patientListViewModel = patientListViewModel, let historyViewModel = historyViewModel {
                PatientListView()
                    .environment(patientListViewModel)
                    .environment(historyViewModel)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Patients")
                    }
            }
            
            if let calendarViewModel = calendarViewModel,
               let appointmentListViewModel = appointmentListViewModel {
                CalendarView()
                    .environment(calendarViewModel)
                    .environment(appointmentListViewModel)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
            }
            
            SettingsView()
                .environment(cloudKitManager)
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
            if historyViewModel == nil {
                historyViewModel = HistoryViewModel(historyManager: historyManager)
            }
            if calendarViewModel == nil {
                calendarViewModel = CalendarViewModel(appointmentManager: appointmentManager)
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
        .environment(HistoryManager.shared)
        .environment(DepartmentManager.shared)
        .environment(CloudKitManager.shared)
        .environment(DataRefreshManager.shared)
}
