//
//  User.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 09/09/25.
//

import Foundation


struct User: Codable {
    var fullName: String
    var email: String
    var role: Role
    var phoneNumber: String
}

enum Role: String, Codable, CaseIterable {
    case headOfConcierge = "Head of Concierge"
    case memberOfConcierge = "Member of Concierge"
}
