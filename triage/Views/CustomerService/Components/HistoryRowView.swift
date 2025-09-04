//
//  HistoryRowView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct HistoryRowView: View {
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
