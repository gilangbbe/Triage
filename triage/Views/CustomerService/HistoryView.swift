//
//  NotificationSheetView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 28/08/25.
//

import SwiftUI


struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let groupedHistory: [(date: String, logs: [History])]
    
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
                    ForEach(groupedHistory, id: \.date) { section in
                        Text(section.date)
                            .font(.headline)
                            .padding(.vertical, 16)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(section.logs.enumerated()), id: \.element.id) { index, log in
                                HistoryRow(historyLog: log)
                                
                                // Add divider except for last log
                                if index < section.logs.count - 1 {
                                    Divider().padding(.horizontal, 4)
                                }
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
        .onAppear {
            print("Grouped logs count:", groupedHistory.count)
        }
    }
}

struct HistoryRow: View {
    let historyLog: History
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("")
                Image(systemName: "square.and.pencil.circle.fill")
                    .font(.system(size:30))
                    .foregroundColor(.brown)
                messageText
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
        case .newPatient(patientName: let patientName):
            return Text("New patient").bold() + Text(" has been added : ") + Text(patientName).bold()
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: historyLog.timestamp)
    }

}


//#Preview {
//    HistoryView()
//}
