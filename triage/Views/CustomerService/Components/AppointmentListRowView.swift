//
//  AppointmentListRowComponent.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct AppointmentListRowView: View {
    private var serviceName: String = "Medical Checkup"
    private var date: String = "22 Agustus 2025"
    private var time: String = "10:00 AM"
    private var package: String = "Paket Merdeka Lite"
    
    var body: some View {
        VStack {
            HStack {
                Text(date)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(serviceName)
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 4)
            HStack {
                Text(time)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(package)
                    .font(.subheadline)
                    .padding(8)
                    .foregroundColor(Color.packageFont)
                    .background(Color.packageBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding()
        .background(Color.appointmentRow)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
