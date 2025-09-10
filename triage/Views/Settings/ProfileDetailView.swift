//
//  ProfileDetailView.swift
//  triage
//
//  Created by Chiquitta Kellie on 10/09/25.
//

import SwiftUI

// MARK: - Profile Detail
struct ProfileDetailView: View {
    @Binding var fullName: String
    @Binding var role: String
    @Binding var phone: String
    @Binding var email: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            labeledField("FULL NAME", placeholder: "Full name", text: $fullName)
            labeledField("ROLE/POSITION", placeholder: "Role or position", text: $role)
            labeledField("PHONE NUMBER", placeholder: "Phone number", text: $phone, keyboard: .numberPad)
            labeledField("WORK EMAIL", placeholder: "name@company.com", text: $email, keyboard: .emailAddress)
            
            Spacer(minLength: 40)
        }
        .padding(.top, 20)
        .padding([.leading, .trailing], 16)
        .background(Color(.systemBackground))
    }
    
    private func labeledField(
        _ title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(hex: "272556").opacity(0.5))
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.title3)
                .foregroundColor(Color(hex: "0F0E46")) // text color
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "F9F9F9"))
                )

        }
    }
}
