//
//  PatientRowView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 26/08/25.
//

import SwiftUI

struct PatientRowView: View {    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 45))
                .foregroundColor(.blue.opacity(0.8))
            VStack (alignment: .leading, spacing: 4) {
                Text("John Doe")
                    .font(.headline)
                Text("Born : 23 April 2019")
                    .font(.subheadline)
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PatientRowView()
}
