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
    
    func saveUserProfile(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            AppConfiguration.sharedUserDefaults?.set(data, forKey: "userProfile")
        }
    }
    
    func loadUserProfile() -> User? {
        guard let data = AppConfiguration.sharedUserDefaults?.data(forKey: "userProfile"), let profile = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func clearUser() {
        AppConfiguration.sharedUserDefaults?.removeObject(forKey: "userProfile")
    }
}
