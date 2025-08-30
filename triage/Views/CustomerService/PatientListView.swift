//
//  PatientListView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 26/08/25.
//

import SwiftUI

struct PatientListView: View {
    // Selected Patient State
    @State var selectedPatientID: UUID? = nil
    @State private var showingNotificationSheet: Bool = false
    @State private var showingAddPatientSheet = false
    @Environment(PatientListViewModel.self) private var viewModel
    
    // Computed property to get patients from viewModel
    private var patients: [Patient] {
        viewModel.filteredPatients
    }
    
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
                    Button(action: {
                        showingAddPatientSheet.toggle()
                    } ) {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar(removing: .sidebarToggle)
            .sheet(isPresented: $showingNotificationSheet) {
                NotificationSheetView()
            }
            .sheet(isPresented: $showingAddPatientSheet) {
                AddPatientView()
                    .frame(width: 800)
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
            destination: PatientDetailView(patient: patient)
        ) {
            PatientRowView(patient: patient)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    PatientListView()
        .environment(PatientListViewModel(patientManager: PatientManager.shared))
}
