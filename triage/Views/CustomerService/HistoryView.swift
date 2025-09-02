//
//  NotificationSheetView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 28/08/25.
//

import SwiftUI


struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let history: [History] = [
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
        History(type: .serviceChoiceUpdate(customerCareName: "Okta", patientName: "Lola Doe", serviceChoice: "Paket Merdeka"), timestamp: Date()),
        History(type: .patientDataUpdate(customerCareName: "Okta", patientName: "Jane Doe"), timestamp: Date()),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button("Back") {
                    dismiss()
                }
                Spacer()
                Text("History Log")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                // Placeholder for alignment
                Color.clear.frame(width: 44)
            }
            .padding()
            .frame(height: 64)
            .shadow(radius: 1)
            

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("28 August 2025")
                        .font(.headline)
                        .padding(.vertical, 16)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(history.enumerated()), id: \.1.id) { index, historyLog in
                            HistoryRow(historyLog: historyLog)
                            if index < history.count - 1 {
                                Divider().padding(.horizontal, 4)
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
}

struct HistoryRow: View {
    let historyLog: History
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("")
                Image(systemName: "square.and.pencil.circle.fill")
                    .font(.system(size:40))
                    .foregroundColor(.blue)
                messageText
            }
            HStack {
                Spacer()
                Text(formattedTime)
                    .font(.caption)
            }
        }
        .padding()
    }
    
    private var messageText: Text {
        switch historyLog.type {
        case .patientDataUpdate(let customerCare, let patient):
            return Text(customerCare).bold() + Text(" updated ") + Text(patient).bold() + Text("'s patient data")
        case .serviceChoiceUpdate(let customerCare, let patient, let service):
            return Text(customerCare).bold() + Text(" updated the service choice to ") + Text(service).bold() + Text(" for ") + Text(patient).bold() + Text("'s appointment")
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: historyLog.timestamp)
    }

}


#Preview {
    HistoryView()
}
