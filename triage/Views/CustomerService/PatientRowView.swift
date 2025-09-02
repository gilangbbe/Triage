//
//  PatientRowView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 26/08/25.
//

import SwiftUI

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        HStack {
            Text("")
            Circle()
                .fill(Color.gray.opacity(0.1))  // you can swap with .secondary, .accentColor, etc.
                .frame(width: 52, height: 52)
                .overlay(
                    Text(initials)
                        .font(.title2)
                )
                .padding(.trailing, 8)
            VStack (alignment: .leading, spacing: 8) {
                Text(patient.fullName)
                    .font(.title3)
                    .fontWeight(.bold)
                Text("DOB : \(formattedBirthDate)")
                    .font(.callout)
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding(.vertical, 12)
    }
    
    private var formattedBirthDate: String {
        if let dateOfBirth = patient.dateOfBirth {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: dateOfBirth)
        } else {
            return "Unknown"
        }
    }
    
    private var initials: String {
        let first = patient.fullName.first?.uppercased() ?? ""
        return first
    }
}

#Preview {
    let samplePatient = Patient(fullName: "John Doe")
    PatientRowView(patient: samplePatient)
}
