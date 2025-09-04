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
    @State private var showingHistorySheet: Bool = false
    @State private var showingAddPatientSheet = false
    @Environment(PatientManager.self) private var patientManager
    @Environment(PatientListViewModel.self) private var patientViewModel
    @Environment(HistoryManager.self) private var historyManager
    @Environment(HistoryViewModel.self) private var historyViewModel
    
    // Computed property to get patients from viewModel
    private var patients: [Patient] {
        patientViewModel.filteredPatients
    }
    
    private var historyLogs: [(date: String, logs: [History])] {
        historyViewModel.groupedLogs
    }
    
    var body: some View {
        @Bindable var patientViewModel = patientViewModel
        
        NavigationSplitView() {
            VStack(spacing: 16) {
                SearchBarPatientView(text: $patientViewModel.searchText)
                
                SegmentedControlFilterView()

                ScrollViewReader { proxy in
                    ZStack(alignment: .trailing) {
                        List(selection: $selectedPatientID) {
                            ForEach(patients) { patient in
                                PatientRowView(patient: patient)
                                    .id(patient.id)
                                    .listRowSeparator(.visible)
                                    .listRowInsets(EdgeInsets())
                                    .accessibilityHidden(true)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let patient = patients[index]
                                    patientViewModel.deletePatient(patient)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .padding(.trailing, 16)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("Patient List"))
                        .accessibilityHint(Text("Scroll the list to view more patients"))
                        
                        // A–Z index on the right
                        NameIndexView(viewModel: patientViewModel, proxy: proxy)
                    }
                }
            }
            .navigationTitle("Patient List")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showingHistorySheet.toggle() } label: { Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90") }
                        .accessibilityLabel(Text("History Log"))
                    Button { showingAddPatientSheet.toggle() } label: { Image(systemName: "plus") }
                        .accessibilityLabel(Text("Add Patient"))
                }
            }
            .toolbar(removing: .sidebarToggle)

            .sheet(isPresented: $showingHistorySheet) {
                HistoryView(groupedHistory: historyLogs)
            }
            .sheet(isPresented: $showingAddPatientSheet) {
                AddPatientView(patientManager: patientManager, historyViewModel: historyViewModel)
                    .frame(width: 800)
                    
            }
        } detail : {
            if let id = selectedPatientID,
               let patient = patients.first(where: { $0.id == id }) {
                PatientDetailView(patient: patient, historyViewModel: historyViewModel)
            } else {
                Text("Select a patient")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(Text("Patient Detail Info"))
            }
        }
    }
}
