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
            Image(systemName: "person.circle.fill")
                .font(.system(size: 45))
                .foregroundColor(patient.gender == .male ? .blue.opacity(0.8) : .pink.opacity(0.8))
            VStack (alignment: .leading, spacing: 4) {
                Text(patient.fullName)
                    .font(.headline)
                Text("Born : \(formattedBirthDate)")
                    .font(.subheadline)
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
}

#Preview {
    let samplePatient = Patient(fullName: "John Doe")
    PatientRowView(patient: samplePatient)
}
