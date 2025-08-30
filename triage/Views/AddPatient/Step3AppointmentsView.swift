//
//  Step3AppointmentsView.swift
//  triage
//
//  Created by Chiquitta Kellie on 30/08/25.
//

import SwiftUI

struct Step3AppointmentsView: View {
    @ObservedObject var viewModel: AddPatientViewModel
    
    var body: some View {
        HStack {
            // Left: Selected Appointments
            VStack(alignment: .leading) {
                Text("Selected Appointments")
                    .font(.headline)
                
                if viewModel.selectedAppointments.isEmpty {
                    Text("No appointments selected yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.selectedAppointments) { appt in
                        VStack(alignment: .leading) {
                            Text(appt.name).bold()
                            Text("\(appt.date, style: .date) @ \(appt.time, style: .time)")
                        }
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: 200)
            .padding()
            
            Divider()
            
            // Right: Filter + Available Packets
            VStack {
                Picker("Filter", selection: $viewModel.selectedCategory) {
                    Text("All").tag("all")
                    Text("Medical Check Up").tag("mcu")
                    Text("Laboratory").tag("lab")
                    Text("Radiology").tag("rad")
                }
                .pickerStyle(.segmented)
                
                ScrollView {
                    ForEach(viewModel.filteredPackets) { packet in
                        AppointmentPacketCard(packet: packet, viewModel: viewModel)
                    }
                }
            }
            .padding()
        }
    }
}

struct AppointmentPacketCard: View {
    let packet: AppointmentPacket
    @ObservedObject var viewModel: AddPatientViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(packet.name).font(.headline)
            Text("Dept: \(packet.department)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            DatePicker(
                "Appointment Date",
                selection: Binding(
                    get: { viewModel.appointmentDates[packet.id] ?? Date() },
                    set: { viewModel.appointmentDates[packet.id] = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            
            Toggle(
                "Needs Consultation",
                isOn: Binding(
                    get: { viewModel.needsConsultation[packet.id] ?? false },
                    set: { viewModel.needsConsultation[packet.id] = $0 }
                )
            )
            
//            Button("Add Appointment") {
//                $viewModel.addAppointment(packet: packet)
//            }
//            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}
