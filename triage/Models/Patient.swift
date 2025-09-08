//
//  Patient.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftData
import CloudKit
import Foundation

@Model
final class Patient {
    var id: UUID = UUID()
    var fullName: String = ""
    var nationalID: String?
    var dateOfBirth: Date?
    var gender: Gender?
    var placeOfBirth: String?
    var registeredAt: Date?
    var phoneNumber: String?
    var address: String?

    // Many-to-many: assigned packages (can be empty)
    @Relationship(deleteRule: .nullify)
    var packages: [Package]?

    // Optional: appointments (can be empty)
    @Relationship(deleteRule: .cascade, inverse: \Appointment.patient)
    var appointments: [Appointment]?

    // UI helpers
    var searchKeywords: String = ""
    var sortKey: String = ""

    init(id: UUID = UUID(), fullName: String) {
        self.id = id
        self.fullName = fullName
        self.searchKeywords = fullName.lowercased()
        self.sortKey = fullName.split(separator: " ").last.map { String($0.prefix(1)).uppercased() } ?? "#"
    }
}

enum Gender: String, Codable, CaseIterable { 
    case male = "Male"
    case female = "Female"
}

// MARK: - Parsing Extension
extension Patient {
    var firstLetter: String {
        fullName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(1)
            .uppercased()
    }
    
    static func parseFromText(_ text: String) -> Patient? {
        let lines = text.components(separatedBy: .newlines)
        var fullName = ""
        var nationalID: String?
        var dateOfBirth: Date?
        var gender: Gender?
        var placeOfBirth: String?
        var phoneNumber: String?
        var address: String?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let components = trimmedLine.components(separatedBy: ":")
            
            if components.count >= 2 {
                let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                
                switch key {
                case "name", "nama", "full name", "nama lengkap":
                    fullName = value
                case "nik", "national id", "ktp", "id":
                    nationalID = value
                case "dob", "date of birth", "tanggal lahir", "lahir":
                    dateOfBirth = dateFormatter.date(from: value)
                case "gender", "jenis kelamin", "kelamin":
                    if value.lowercased().contains("man") || value.lowercased().contains("pria") || value.lowercased().contains("laki") {
                        gender = .male
                    } else if value.lowercased().contains("woman") || value.lowercased().contains("wanita") || value.lowercased().contains("perempuan") {
                        gender = .female
                    }
                case "place of birth", "tempat lahir", "born":
                    placeOfBirth = value
                case "phone", "telephone", "telepon", "hp", "no hp", "nomor hp":
                    phoneNumber = value
                case "address", "alamat", "addr":
                    address = value
                default:
                    // Ignore unrecognized keys
                    break
                }
            }
        }
        
        // Only create patient if we have at least full name
        if !fullName.isEmpty {
            let patient = Patient(fullName: fullName)
            patient.nationalID = nationalID
            patient.dateOfBirth = dateOfBirth
            patient.gender = gender
            patient.placeOfBirth = placeOfBirth
            patient.phoneNumber = phoneNumber
            patient.address = address
            patient.registeredAt = Date()
            return patient
        }
        
        return nil
    }
}
