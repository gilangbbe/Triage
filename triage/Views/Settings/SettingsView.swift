//
//  SettingsView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct SettingsView: View {
    // Single customer care profile
    var user: User?
    @State var fullName: String = ""
    @State var role: String = ""
    @State var phone: String = ""
    @State var email: String = ""
    
    init() {
        let user = UserManager.shared.loadUserProfile()
        _fullName = State(initialValue: user?.fullName ?? "")
        _role = State(initialValue: user?.role.rawValue ?? "")
        _phone = State(initialValue: user?.phoneNumber ?? "")
        _email = State(initialValue: user?.email ?? "")
        
        self.user = user
    }
    
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
            VStack {
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
                            .foregroundColor(Color("TextPrimary").opacity(0.8))
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
                            .foregroundColor(Color("TextPrimary").opacity(0.8))
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
                            .foregroundColor(Color("TextPrimary").opacity(0.8))
                    }
                    .headerProminence(.increased)
                }
            }
            .listSectionSpacing(20)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
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
            VStack {
                Spacer().frame(height: 46)
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
                    EmptyView()
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .background(Color(.systemBackground))
        .overlay(
            VStack {
                Spacer().frame(height: 200)    // offset from top
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                Spacer()
            },
            alignment: .leading
        )
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
                .foregroundColor(isSelected ? Color("ButtonPrimary") : Color("TextPrimary"))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading) // stretch full width
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            (isSelected ? Color("TextPrimary") : Color("BackgroundSettings"))
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
                        .foregroundColor(Color("TextPrimary"))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color("ButtonPrimary") : Color("TextPrimary"))
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color("TextPrimary") : Color("BackgroundSettings"))
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
