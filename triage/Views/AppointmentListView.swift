//
//  AppointmentListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AppointmentListView: View {
    @Environment(AppointmentManager.self) private var appointmentManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appointmentManager.appointments, id: \.id) { appointment in
                    AppointmentRowView(appointment: appointment)
                }
                .onDelete { indexSet in
                    appointmentManager.deleteAppointments(at: indexSet)
                }
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Appointment") {
                        // Add appointment action
                    }
                }
            }
        }
    }
}

struct AppointmentRowView: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(appointment.title)
                .font(.headline)
            
            HStack {
                Text(appointment.department.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(appointment.start, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let patient = appointment.patient {
                Text("Patient: \(patient.fullName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AppointmentListView()
        .environment(AppointmentManager.shared)
}
