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
                AddAppointmentView()
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
                Text(appointment.title)
                    .font(.headline)
                
                Spacer()
                
                Text(appointment.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            HStack {
                Text(appointment.department.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(appointment.start, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(appointment.start, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let patient = appointment.patient {
                Text("Patient: \(patient.fullName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var statusColor: Color {
        switch appointment.status {
        case .scheduled:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        case .noShow:
            return .orange
        }
    }
}

#Preview {
    AppointmentListView()
        .environment(AppointmentListViewModel(appointmentManager: AppointmentManager.shared))
}
