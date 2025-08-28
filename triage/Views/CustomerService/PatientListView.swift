//
//  PatientListView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 26/08/25.
//

import SwiftUI

class Patient: Identifiable {
    var id: UUID = UUID()
    var name: String
    var birthdate: Date
    
    init(name: String, birthdate: Date) {
        self.name = name
        self.birthdate = birthdate
    }
}

struct PatientListView: View {
    // Selected Patient State
    @State var selectedPatientID: UUID? = nil
    @State private var showingNotificationSheet: Bool = false
    @Environment(OrderListViewModel.self) private var viewModel
    
    let patients: [Patient] = [
        Patient(name: "John Doe", birthdate: Date(timeIntervalSince1970: 1555977600)),
        Patient(name: "Jane Smith", birthdate: Date(timeIntervalSince1970: 946684800)),
        Patient(name: "Michael Brown", birthdate: Date(timeIntervalSince1970: 631152000))
    ]
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationSplitView() {
            VStack(spacing: 16) {
                SearchBarPatient(text: $viewModel.searchText)
                
                SegmentedControlFilter()
                
                List(patients) { patient in
                    PatientRowNavigationLink(
                            patient: patient,
                            isSelected: selectedPatientID == patient.id
                        )
                        .listRowInsets(EdgeInsets())
                }
                .padding(.horizontal, 8)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Patient List")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNotificationSheet.toggle()
                    } ) {
                        Image(systemName: "bell")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {} ) {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
            .sheet(isPresented: $showingNotificationSheet) {
                NotificationSheetView()
            }
        } detail : {
            
        }
    }
}

struct SearchBarPatient: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search Patient", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
    }
}

struct SegmentedControlFilter: View {
    @State private var selectedSegment = 0
    
    var body : some View {
        VStack {
            Picker("Options", selection: $selectedSegment) {
                Text("MCU").tag(0)
                Text("Radiology").tag(1)
                Text("Laboratorium").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
        }
    }
}

struct PatientRowNavigationLink: View {
    let patient: Patient
    let isSelected: Bool
    
    var body: some View {
        NavigationLink(
            destination: PatientDetailView()
        ) {
            PatientRowView()
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    PatientListView()
        .environment(OrderListViewModel(dataManager: DataManager.shared))
}
