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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox("Patient Information") {
                        VStack(alignment: .leading) {
                            Text("NIK: \(viewModel.nik)")
                            Text("Name: \(viewModel.name)")
                            Text("DOB: \(viewModel.dobString)")
                            Text("Phone: \(viewModel.phoneNumber)")
                            Text("Address: \(viewModel.address)")
                        }
                    }
                    
                    GroupBox("Appointments") {
                        ForEach(viewModel.selectedAppointments) { appt in
                            VStack(alignment: .leading) {
                                Text(appt.name).bold()
                                Text("Date: \(appt.date, style: .date) @ \(appt.time)")
                                if appt.consultation {
                                    Text("Consultation required").foregroundColor(.secondary)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding()
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

                       // draw line except after the last circle
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
