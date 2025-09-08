//
//  DepartmentManager.swift
//  triage
//
//  Created by Assistant on 05/09/25.
//

import Foundation
import SwiftData

@Observable
class DepartmentManager {
    static let shared = DepartmentManager()
    
    private var modelContext: ModelContext?
    var departments: [Department] = []
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadDepartments()
    }
    
    func loadDepartments() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Department>(
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            departments = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch departments: \(error)")
            departments = []
        }
    }
    
    func addDepartment(_ department: Department) {
        guard let modelContext = modelContext else { return }
        
        modelContext.insert(department)
        
        do {
            try modelContext.save()
            loadDepartments()
        } catch {
            print("Failed to save department: \(error)")
        }
    }
    
    func updateDepartment(_ department: Department) {
        guard let modelContext = modelContext else { return }
        
        do {
            try modelContext.save()
            loadDepartments()
        } catch {
            print("Failed to update department: \(error)")
        }
    }
    
    func deleteDepartment(_ department: Department) {
        guard let modelContext = modelContext else { return }
        
        modelContext.delete(department)
        
        do {
            try modelContext.save()
            loadDepartments()
        } catch {
            print("Failed to delete department: \(error)")
        }
    }
    
    func getDepartmentByName(_ name: String) -> Department? {
        return departments.first { $0.name == name }
    }
    
    func getOrCreateDepartment(name: String, maxSlot: Int = 3) -> Department {
        if let existing = getDepartmentByName(name) {
            return existing
        } else {
            let newDepartment = Department(name: name, maxSlot: maxSlot)
            addDepartment(newDepartment)
            return newDepartment
        }
    }
}
