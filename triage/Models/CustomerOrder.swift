//
//  CustomerOrder.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import SwiftData

@Model
final class CustomerOrder {
    var id: UUID
    var name: String
    var email: String
    var address: String
    var phoneNumber: String?
    var orderDetails: String?
    var dateCreated: Date
    var status: OrderStatus
    
    init(name: String = "", email: String = "", address: String = "", phoneNumber: String? = nil, orderDetails: String? = nil) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.address = address
        self.phoneNumber = phoneNumber
        self.orderDetails = orderDetails
        self.dateCreated = Date()
        self.status = .pending
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Parsing Extension
extension CustomerOrder {
    static func parseFromText(_ text: String) -> CustomerOrder? {
        let lines = text.components(separatedBy: .newlines)
        var name = ""
        var email = ""
        var address = ""
        var phoneNumber: String?
        var orderDetails: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let components = trimmedLine.components(separatedBy: ":")
            
            if components.count >= 2 {
                let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
                
                switch key {
                case "name", "nama":
                    name = value
                case "email", "e-mail":
                    email = value
                case "address", "alamat", "addr":
                    address = value
                case "phone", "telephone", "telepon", "hp", "no hp":
                    phoneNumber = value
                case "order", "pesanan", "details":
                    orderDetails = value
                default:
                    // Ignore unrecognized keys
                    break
                }
            }
        }
        
        // Only create order if we have at least name and one contact method
        if !name.isEmpty && (!email.isEmpty || !address.isEmpty) {
            return CustomerOrder(
                name: name,
                email: email,
                address: address,
                phoneNumber: phoneNumber,
                orderDetails: orderDetails
            )
        }
        
        return nil
    }
}