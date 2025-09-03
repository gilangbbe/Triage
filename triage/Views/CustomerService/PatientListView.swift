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
    @Environment(PatientManager.self) private var patientManager
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

                ScrollViewReader { proxy in
                    ZStack(alignment: .trailing) {
                        List(selection: $selectedPatientID) {
                            ForEach(patients) { patient in
                                PatientRowView(patient: patient)
                                    .id(patient.id)
                                    .listRowSeparator(.visible)
                                    .listRowInsets(EdgeInsets())
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let patient = patients[index]
                                    viewModel.deletePatient(patient)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .padding(.trailing, 16)
                        // A–Z index on the right
                        NameIndex(viewModel: viewModel, proxy: proxy)
                    }
                }
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
//                NotificationSheetView()
            }
            .sheet(isPresented: $showingAddPatientSheet) {
                AddPatientView(
                    patientManager: patientManager,
                    appointmentManager: AppointmentManager.shared,
                    packageManager: PackageManager.shared
                )
                .frame(width: 800)
            }
        } detail : {
            if let id = selectedPatientID,
               let patient = patients.first(where: { $0.id == id }) {
                PatientDetailView(patient: patient)
            } else {
                Text("Select a patient")
                    .foregroundStyle(.secondary)
            }
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
        .padding(.horizontal, 18)
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
            .padding(.horizontal, 18)
        }
    }
}

struct NameIndex: View {
    @Bindable var viewModel: PatientListViewModel
    var proxy: ScrollViewProxy
    
    // Always show A–Z
    let sectionTitles = (65...90).map { String(UnicodeScalar($0)!) }
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                ForEach(sectionTitles, id: \.self) { letter in
                    Button(action: {
                        withAnimation {
                            if viewModel.selectedLetter == letter {
                                // 👇 tapped the same letter again → reset filter
                                viewModel.selectedLetter = nil
                            } else {
                                viewModel.selectedLetter = letter
                                if let firstPatient = viewModel.filteredPatients.first(where: { $0.firstLetter == letter }) {
                                    proxy.scrollTo(firstPatient.id, anchor: .top)
                                }
                            }
                        }
                    }) {
                        Text(letter)
                            .font(.caption2)
                            .foregroundColor(viewModel.selectedLetter == letter ? .blue : .gray)
                            .padding(.vertical, 1)
                            .frame(width: 24, height: 20)
                    }
                }
            }
        }
    }
}





#Preview {
    PatientListView()
        .environment(PatientListViewModel(patientManager: PatientManager.shared))
        .environment(PatientManager.shared)
}
