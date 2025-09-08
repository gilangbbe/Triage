//
//  AppointmentManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class TimeSlotManager {
    static let shared = TimeSlotManager()
    
    var timeSlots: [TimeSlot] = []
    private var modelContext: ModelContext?
    
    private init() {
        loadTimeSlots()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTimeSlots()
    }
    
    // MARK: - Data Loading
    func loadTimeSlots() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<TimeSlot>(
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            timeSlots = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch appointments: \(error)")
            timeSlots = []
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
