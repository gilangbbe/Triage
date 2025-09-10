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
            List(selection: $selectedSection) {
                // Profile Section
                Section {
                    ProfileRowView(
                        fullName: fullName,
                        isSelected: selectedSection == .profile
                    )
                    .tag(SettingsSection.profile)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } header: {
                    Text("CUSTOMER CARE IDENTITY")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#272556").opacity(0.5))
                }
                .headerProminence(.increased)
                
                // Service Setup Section
                Section {
                    SettingsRowView(
                        section: .packages,
                        isSelected: selectedSection == .packages
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } header: {
                    Text("SERVICE SETUP")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#272556").opacity(0.5))
                }
                .headerProminence(.increased)
                
                // Keyboard Extension Section
                Section {
                    SettingsRowView(
                        section: .setupInstructions,
                        isSelected: selectedSection == .setupInstructions
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    SettingsRowView(
                        section: .quickReplies,
                        isSelected: selectedSection == .quickReplies
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } header: {
                    Text("KEYBOARD EXTENSION")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#272556").opacity(0.5))
                }
                .headerProminence(.increased)
            }
            .listSectionSpacing(20)
            .scrollContentBackground(.hidden)
            .background(Color.white)
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
                KeyboardInstructionView()
            case .quickReplies:
                QuickRepliesPaneView()
            case .none:
                PlaceholderDetailView(
                    title: "Settings",
                    description: "Select a settings category"
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar Row Views

struct SettingsRowView: View {
    let section: SettingsView.SettingsSection
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(section.rawValue)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading) // stretch full width
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            (isSelected ? Color(hex: "#0F0E46") : Color(hex: "#F9F9F9"))
                .ignoresSafeArea()
        )
        .cornerRadius(6)
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
                        .foregroundColor(isSelected ? .white : .primary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color(hex: "#0F0E46") : Color(hex: "#F9F9F9"))
        )
    }
    
    private func initials(_ name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let second = comps.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
}




#Preview {
    SettingsView()
        .environment(PackageManager.shared)
        .environment(QuickReplyManager.shared)
}
