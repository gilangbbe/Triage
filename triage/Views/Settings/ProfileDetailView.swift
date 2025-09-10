//
//  ProfileDetailView.swift
//  triage
//
//  Created by Chiquitta Kellie on 10/09/25.
//

import SwiftUI

struct ProfileDetailView: View {
    @Binding var fullName: String
    @Binding var role: String
    @Binding var phone: String
    @Binding var email: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                labeledField(
                    title: "FULL NAME",
                    placeholder: "Full name",
                    text: $fullName
                )
                
                labeledField(
                    title: "ROLE/POSITION",
                    placeholder: "Role or position",
                    text: $role
                )
                
                labeledField(
                    title: "PHONE NUMBER",
                    placeholder: "Phone number",
                    text: $phone,
                    keyboard: .numberPad
                )
                
                labeledField(
                    title: "WORK EMAIL",
                    placeholder: "name@company.com",
                    text: $email,
                    keyboard: .emailAddress
                )
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func labeledField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboard)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Placeholder View

struct PlaceholderDetailView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gear")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Coming soon")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
