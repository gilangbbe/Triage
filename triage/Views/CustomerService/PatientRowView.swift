//
//  PatientRowView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 26/08/25.
//

import SwiftUI

struct PatientRowView: View {
    var isSelected: Bool = false
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 4) {
                Text("John Doe")
                    .font(.headline)
                Text("Born : 23 April 2019")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(.blue.opacity(isSelected ? 0.8 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PatientRowView()
}
