//
//  DepartmentManager.swift
//  triage
//
//  Created by Assistant on 05/09/25.
//

import Foundation
import SwiftData
import CloudKit

@Observable
class DepartmentManager: CloudKitSyncable {
    typealias ModelType = Department
    
    static let shared = DepartmentManager()
    
    private var modelContext: ModelContext?
    var departments: [Department] = []
    private let cloudKitHelper = CloudKitHelper.shared
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadDepartments() // Load any additional local data
        }
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
            
            // Sync to CloudKit
            Task {
                await syncToCloudKit(department)
            }
        } catch {
            print("Failed to save department: \(error)")
        }
    }
    
    func updateDepartment(_ department: Department) {
        guard let modelContext = modelContext else { return }
        
        do {
            try modelContext.save()
            loadDepartments()
            
            // Sync to CloudKit
            Task {
                await syncToCloudKit(department)
            }
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
            
            // Delete from CloudKit
            Task {
                await deleteFromCloudKit(department)
            }
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
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: Department) async {
        let record = CKRecord(recordType: "Department", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["name"] = item.name
        record["maxSlot"] = item.maxSlot
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync department to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: Department) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: Department.self)
        } catch {
            print("❌ Failed to delete department from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            let records = try await cloudKitHelper.fetchRecords(ofType: "Department")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if department already exists in SwiftData database
                        let departmentId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        
                        // Query SwiftData directly to check for existing record
                        guard let context = modelContext else { continue }
                        
                        let descriptor = FetchDescriptor<Department>(
                            predicate: #Predicate<Department> { department in
                                department.id == departmentId
                            }
                        )
                        
                        do {
                            let existingDepartments = try context.fetch(descriptor)
                            if existingDepartments.isEmpty {
                                // Only create if doesn't exist in database
                                let department = Department(
                                    id: departmentId,
                                    name: record["name"] as? String ?? "",
                                    maxSlot: record["maxSlot"] as? Int ?? 3
                                )
                                
                                context.insert(department)
                                try context.save()
                                print("✅ Added new department from CloudKit: \(department.name)")
                            } else {
                                print("ℹ️ Department already exists locally: \(record["name"] as? String ?? "Unknown")")
                            }
                        } catch {
                            print("❌ Failed to check/save department from CloudKit: \(error)")
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download department: \(error.localizedDescription)")
                    }
                }
                loadDepartments() // Refresh the departments array
            }
        } catch {
            print("❌ Failed to load departments from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for department in departments {
            await syncToCloudKit(department)
        }
    }
}
