//
//  AddOrderViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import Foundation
import SwiftUI

@Observable
class AddOrderViewModel {
    var name = ""
    var email = ""
    var address = ""
    var phoneNumber = ""
    var orderDetails = ""
    var rawText = ""
    var showingRawTextInput = false
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    var isValidOrder: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
         !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func saveOrder() {
        guard isValidOrder else { return }
        
        let order = CustomerOrder(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            orderDetails: orderDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : orderDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addOrder(order)
        clearForm()
    }
    
    func parseFromRawText() {
        guard let parsedOrder = CustomerOrder.parseFromText(rawText) else { return }
        
        name = parsedOrder.name
        email = parsedOrder.email
        address = parsedOrder.address
        phoneNumber = parsedOrder.phoneNumber ?? ""
        orderDetails = parsedOrder.orderDetails ?? ""
        
        showingRawTextInput = false
        rawText = ""
    }
    
    func clearForm() {
        name = ""
        email = ""
        address = ""
        phoneNumber = ""
        orderDetails = ""
        rawText = ""
    }
}

