//
//  AppointmentListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AppointmentListView: View {
    @Environment(AppointmentListViewModel.self) private var viewModel
    @State private var showingAddAppointment = false
    @State private var searchText = ""
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedSegment) {
                    Text("All").tag(0)
                    Text("Today").tag(1)
                    Text("Upcoming").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    ForEach(filteredAppointments, id: \.id) { appointment in
                        AppointmentRowView(appointment: appointment)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteAppointments(at: indexSet, from: filteredAppointments)
                    }
                }
            }
            .navigationTitle("Appointments")
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                viewModel.searchText = newValue
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Appointment") {
                        showingAddAppointment = true
                    }
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentView(appointmentManager: viewModel.manager)
            }
        }
    }
    
    private var filteredAppointments: [Appointment] {
        switch selectedSegment {
        case 1:
            return viewModel.todaysAppointments
        case 2:
            return viewModel.upcomingAppointments
        default:
            return viewModel.filteredAppointments
        }
    }
}

struct AppointmentRowView: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(appointment.name)
                    .font(.headline)
            }
            
            HStack {
                VStack(alignment: .trailing) {
                    Text(appointment.timeSlot.startTime, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Patient: \(appointment.patient.fullName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AppointmentListView()
        .environment(AppointmentListViewModel(appointmentManager: AppointmentManager.shared))
}
