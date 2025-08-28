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
    @Environment(OrderListViewModel.self) private var viewModel
    
    let patients: [Patient] = [
        Patient(name: "John Doe", birthdate: Date(timeIntervalSince1970: 1555977600)),
        Patient(name: "Jane Smith", birthdate: Date(timeIntervalSince1970: 946684800)),
        Patient(name: "Michael Brown", birthdate: Date(timeIntervalSince1970: 631152000))
    ]
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationView() {
            VStack(spacing: 16) {
                SearchBarPatient(text: $viewModel.searchText)
                
                SegmentedControlFilter()
                
                
                List(patients) { patient in
                    PatientRowView(isSelected: selectedPatientID == patient.id)
                        .onTapGesture {
                            selectedPatientID = patient.id
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.visible)
                }
                .padding(.horizontal, 8)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Patient List")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {} ) {
                        Image(systemName: "bell")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {} ) {
                        Image(systemName: "plus")
                    }
                }
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


#Preview {
    PatientListView()
        .environment(OrderListViewModel(dataManager: DataManager.shared))
}
