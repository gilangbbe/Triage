//
//  SearchBarPatientView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct SearchBarPatientView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search Patient", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Search Bar Patient"))
    }
}
