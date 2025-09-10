//
//  SignUpViewModel.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 09/09/25.
//

import Foundation

class SignUpViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var role: Role = .memberOfConcierge
    @Published var phoneNumber = ""
    
    init() {
        if let savedUser = UserManager.shared.loadUserProfile() {
            fullName = savedUser.fullName
            email = savedUser.email
            role = savedUser.role
            phoneNumber = savedUser.phoneNumber
        }
    }
    
    func completeOnboarding() -> User {
        let user = User(fullName: fullName, email: email, role: role, phoneNumber: phoneNumber)
        UserManager.shared.saveUserProfile(user)
        return user
    }
}
