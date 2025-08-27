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
    @EnvironmentObject var viewModel: OrderListViewModel
    
    let patients: [Patient] = [
        Patient(name: "John Doe", birthdate: Date(timeIntervalSince1970: 1555977600)),
        Patient(name: "Jane Smith", birthdate: Date(timeIntervalSince1970: 946684800)),
        Patient(name: "Michael Brown", birthdate: Date(timeIntervalSince1970: 631152000))
    ]
    
    var body: some View {
        NavigationView() {
            VStack {
                SearchBarPatient(text: $viewModel.searchText)
                
                List(patients) { patient in
                    PatientRowView(isSelected: selectedPatientID == patient.id)
                        .onTapGesture {
                            selectedPatientID = patient.id
                        }
                        .listRowInsets(EdgeInsets())
                }
                .scrollContentBackground(.hidden)
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
        .padding(.horizontal, 28)
    }
}


#Preview {
    PatientListView()
        .environmentObject(OrderListViewModel())
}
