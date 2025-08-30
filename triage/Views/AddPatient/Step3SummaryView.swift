//
//  Step3SummaryView.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//
import SwiftUI
import Foundation

struct Step3SummaryView: View {
    @ObservedObject var viewModel: AddPatientViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Patient Information")) {
                    
                    // NIK
                    VStack(alignment: .leading) {
                        Text("NIK")
                        TextField("Enter NIK", text: Binding(
                            get: { viewModel.nik ?? "" },
                            set: { viewModel.nik = $0 }
                        ))
                        .keyboardType(.numberPad)
                    }
                    
                    // Full Name (mandatory)
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            Text("Full Name")
                            Text("*").foregroundColor(.red)
                        }
                        TextField("Enter full name", text: $viewModel.name)
                    }
                    
                    // Date of Birth
                    VStack(alignment: .leading) {
                        Text("Date of Birth")
                        
                        DatePicker(
                            "Select date",
                            selection: Binding(
                                get: { viewModel.dob ?? Date() },   // fallback if nil
                                set: { viewModel.dob = $0 }         // write back
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                    
                    // Phone
                    VStack(alignment: .leading) {
                        Text("Phone Number")
                        TextField("Enter phone number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    // Address
                    VStack(alignment: .leading) {
                        Text("Address")
                        TextField("Enter address", text: $viewModel.address, axis: .vertical)
                    }
                    
                    // Gender
                    VStack(alignment: .leading) {
                        Text("Gender")
                        Picker("Gender", selection: Binding(
                            get: { viewModel.gender ?? "L" },
                            set: { viewModel.gender = $0 }
                        )) {
                            Text("L").tag("L")
                            Text("P").tag("P")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section(header: Text("Appointments")) {
                    if viewModel.selectedAppointments.isEmpty {
                        Text("No appointments yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.selectedAppointments) { appt in
                            VStack(alignment: .leading) {
                                Text(appt.name).bold()
                                Text("Date: \(appt.date, style: .date) @ \(appt.time)")
                                if appt.consultation {
                                    Text("Consultation required")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // ===== Step Indicators at Bottom =====
            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { i in
                    HStack(spacing: 0) {
                        Circle()
                            .fill(i <= 3 ? Color(hex: "#0F0E46") : Color(hex: "#F0F0F7"))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(i)")
                                    .foregroundColor(i <= 3 ? .white : .black)
                            )
                        
                        if i < 3 {
                            Rectangle()
                                .fill(Color(hex: "#0F0E46"))
                                .frame(height: 2)
                                .frame(maxWidth: 28)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}
