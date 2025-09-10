//
//  SignUpView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 09/09/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Binding var user: User?
    
    private var sidebarWidth: CGFloat {
        max(UIScreen.main.bounds.width * 0.40, 500)
    }

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Image("CihosBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .frame(width: sidebarWidth)

            // MARK: Detail
            ZStack {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Text("Please complete your information below to begin")
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 24)
                    
                    SignUpTextField(
                        icon: "person.text.rectangle.fill",
                        label: "FULL NAME",
                        placeholder: "Ex. Jason Statam",
                        text: $viewModel.fullName
                    )
                    
                    SignUpTextField(
                        icon: "envelope.badge.person.crop.fill",
                        label: "WORK EMAIL",
                        placeholder: "Ex. jasonstatam@gmail.com",
                        text: $viewModel.email
                    )
                    
                    SignUpTextField(
                        icon: "phone.fill",
                        label: "PHONE NUMBER",
                        placeholder: "Ex. 081312345678",
                        text: $viewModel.phoneNumber
                    )
                    
                    VStack {
                        HStack {
                            Image(systemName: "display")
                                .foregroundColor(.gray)
                            Text("ROLE/POSITION")
                                .foregroundColor(.gray)
                            Spacer()
                            Picker(
                                "Select Role",
                                selection: Binding(
                                    get: { viewModel.role },
                                    set: { viewModel.role = $0 }
                                )
                            ) {
                                ForEach(Role.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role as Role?)
                                }
                            }
                            .frame(width: 300, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ? Color.clear : Color.placeholder)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                            .labelsHidden()
                        }
                    }
                    .padding(.vertical, 16)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            user = viewModel.completeOnboarding()
                        }) {
                            Label("Start", systemImage: "chevron.right.circle.fill")
                                .padding(12)
                                .frame(width: 125)
                                .foregroundColor(.signInBackground)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 700)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.signInBackground)
        }
    }
}
//
//#Preview {
//    SignUpView()
//}
//
//
//#Preview {
//    SignUpView()
//}
