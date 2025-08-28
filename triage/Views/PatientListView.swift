//
//  PatientListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct PatientListView: View {
    @Environment(PatientListViewModel.self) private var viewModel
    @State private var showingAddPatient = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredPatients, id: \.id) { patient in
                    PatientRowView(patient: patient)
                        .onTapGesture {
                            // Handle patient selection
                        }
                }
                .onDelete { indexSet in
                    viewModel.deletePatients(at: indexSet, from: viewModel.filteredPatients)
                }
            }
            .navigationTitle("Patients")
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                viewModel.searchText = newValue
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Patient") {
                        showingAddPatient = true
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                AddPatientView()
            }
        }
    }
}

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(patient.fullName)
                .font(.headline)
            
            HStack {
                if let gender = patient.gender {
                    Text(gender.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(gender == .male ? Color.blue.opacity(0.2) : Color.pink.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if let phoneNumber = patient.phoneNumber {
                    Text(phoneNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let registeredAt = patient.registeredAt {
                    Text(registeredAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let nationalID = patient.nationalID {
                Text("NIK: \(nationalID)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PatientListView()
        .environment(PatientListViewModel(patientManager: PatientManager.shared))
}
