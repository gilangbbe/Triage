//
//  SettingsView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct SettingsView: View {
    // Single customer care profile
    @State private var fullName: String = "Ayu Lestari Wulandari"
    @State private var role: String = "Customer Care Coordinator"
    @State private var phone: String = "08123456789"
    @State private var email: String = "ayulestariwu@ciputrahospital.com"
    
    // Navigation state
    @State private var selectedSection: SettingsSection? = .profile
    
    enum SettingsSection: String, CaseIterable, Identifiable {
        case profile = "Customer Care Profile"
        case packages = "Add Healthcare Catalog"
        case setupInstructions = "Setup Instructions"
        case quickReplies = "Quick Replies"
        
        var id: String { rawValue }
        
        var category: String {
            switch self {
            case .profile: return "USER PROFILE"
            case .packages: return "SERVICE SETUP"
            case .setupInstructions, .quickReplies: return "KEYBOARD EXTENSION"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 16) {
                ScrollViewReader { proxy in
                    List(selection: $selectedSection) {
                        // Profile Section
                        Section("CUSTOMER CARE IDENTITY") {
                            ProfileRowView(
                                fullName: fullName,
                                isSelected: selectedSection == .profile
                            )
                            .tag(SettingsSection.profile)
                        }
                        
                        // Service Setup Section
                        Section("SERVICE SETUP") {
                            SettingsRowView(
                                section: .packages,
                                isSelected: selectedSection == .packages
                            )
                        }
                        
                        // Keyboard Extension Section
                        Section("KEYBOARD EXTENSION") {
                            SettingsRowView(
                                section: .setupInstructions,
                                isSelected: selectedSection == .setupInstructions
                            )
                            SettingsRowView(
                                section: .quickReplies,
                                isSelected: selectedSection == .quickReplies
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar(removing: .sidebarToggle)
            .onAppear {
                if selectedSection == nil {
                    selectedSection = .profile
                }
            }
        } detail: {
            // Detail View
            switch selectedSection {
            case .profile:
                ProfileDetailView(
                    fullName: $fullName,
                    role: $role,
                    phone: $phone,
                    email: $email
                )
            case .packages:
                HealthCareCatalogView()
            case .setupInstructions:
                PlaceholderDetailView(title: "Setup Instructions", description: "Keyboard extension setup guide")
            case .quickReplies:
                PlaceholderDetailView(title: "Quick Replies", description: "Manage quick reply templates")
            case .none:
                PlaceholderDetailView(title: "Settings", description: "Select a settings category")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    // MARK: - Helper Functions
    private func initials(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let second = comps.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
}

// MARK: - Supporting Views

struct SettingsRowView: View {
    let section: SettingsView.SettingsSection
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(section.rawValue)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            isSelected ? Color.accentColor : Color.placeholder,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .tag(section)
    }
}

struct ProfileRowView: View {
    let fullName: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(initials(fullName))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isSelected ? .white : .primary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            isSelected ? Color.accentColor : Color.placeholder,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
    
    private func initials(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let second = comps.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
}

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

#Preview {
    SettingsView()
}
