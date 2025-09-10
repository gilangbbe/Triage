//
//  UserManager.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 09/09/25.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private let profileKey = "userProfile"
    private let loginKey = "isLoggedIn"
    
    func saveUserProfile(_ user: User?) {
        if let data = try? JSONEncoder().encode(user) {
            AppConfiguration.sharedUserDefaults?.set(data, forKey: profileKey)
            AppConfiguration.sharedUserDefaults?.set(true, forKey: loginKey)
        }
    }
    
    func loadUserProfile() -> User? {
        guard let data = AppConfiguration.sharedUserDefaults?.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func isLoggedIn() -> Bool {
        return AppConfiguration.sharedUserDefaults?.bool(forKey: loginKey) ?? false
    }
    
    func clearUser() {
        AppConfiguration.sharedUserDefaults?.removeObject(forKey: profileKey)
        AppConfiguration.sharedUserDefaults?.set(false, forKey: loginKey)
    }
}

