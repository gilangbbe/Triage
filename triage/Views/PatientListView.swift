//
//  PatientListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct PatientListView: View {
    @Environment(PatientManager.self) private var patientManager
    @Environment(PatientListViewModel.self) private var viewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(patientManager.patients, id: \.id) { patient in
                    PatientRowView(patient: patient)
                }
                .onDelete { indexSet in
                    patientManager.deletePatients(at: indexSet)
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Patient") {
                        // Add patient action
                    }
                }
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
            
            if let phoneNumber = patient.phoneNumber {
                Text(phoneNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let registeredAt = patient.registeredAt {
                Text("Registered: \(registeredAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PatientListView()
        .environment(PatientManager.shared)
}
