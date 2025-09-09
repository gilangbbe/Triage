//
//  PackageManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine
import CloudKit

@Observable
class PackageManager: CloudKitSyncable {
    typealias ModelType = Package
    
    static let shared = PackageManager()
    
    var packages: [Package] = []
    private var modelContext: ModelContext?
    private let cloudKitHelper = CloudKitHelper.shared
    
    private init() {
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFromCloudKit()
            loadPackages() // Load any additional local data
        }
    }
    
    // MARK: - CRUD Operations
    func addPackage(_ package: Package) {
        guard let context = modelContext else { return }
        
        context.insert(package)
        saveContext()
        loadPackages()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(package)
        }
    }
    
    func updatePackage(_ package: Package) {
        saveContext()
        loadPackages()
        
        // Sync to CloudKit
        Task {
            await syncToCloudKit(package)
        }
    }
    
    func deletePackage(_ package: Package) {
        guard let context = modelContext else { return }
        
        context.delete(package)
        saveContext()
        loadPackages()
        
        // Delete from CloudKit
        Task {
            await deleteFromCloudKit(package)
        }
    }
    
    func deletePackages(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        var packagesToDelete: [Package] = []
        for index in indexSet {
            let package = packages[index]
            packagesToDelete.append(package)
            context.delete(package)
        }
        saveContext()
        loadPackages()
        
        // Delete from CloudKit
        Task {
            for package in packagesToDelete {
                await deleteFromCloudKit(package)
            }
        }
    }
    
    // MARK: - Data Loading
    func loadPackages() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Package>(
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            packages = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch packages: \(error)")
            packages = []
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
    
    // MARK: - Search and Filter
    func searchPackages(query: String) -> [Package] {
        if query.isEmpty {
            return packages
        }
        
        return packages.filter { package in
            package.name.localizedCaseInsensitiveContains(query) ||
            package.descriptionText?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    // MARK: - Patient-Package Relationships
    func assignPackageToPatient(_ package: Package, patient: Patient) {
        if package.patients?.contains(where: { $0.id == patient.id }) != true {
            if package.patients == nil {
                package.patients = []
            }
            package.patients?.append(patient)
            saveContext()
            loadPackages()
        }
    }
    
    func removePackageFromPatient(_ package: Package, patient: Patient) {
        package.patients?.removeAll { $0.id == patient.id }
        saveContext()
        loadPackages()
    }
    
    func packagesForPatient(_ patient: Patient) -> [Package] {
        return packages.filter { package in
            package.patients?.contains { $0.id == patient.id } == true
        }
    }
    
    // MARK: - CloudKit Sync Implementation
    func syncToCloudKit(_ item: Package) async {
        let record = CKRecord(recordType: "Package", recordID: CKRecord.ID(recordName: item.id.uuidString))
        record["name"] = item.name
        record["descriptionText"] = item.descriptionText
        
        // Reference to department
        if let department = item.department {
            let departmentRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: department.id.uuidString), action: .deleteSelf)
            record["department"] = departmentRef
        }
        
        do {
            try await cloudKitHelper.save(record, for: item)
        } catch {
            print("❌ Failed to sync package to CloudKit: \(error.localizedDescription)")
        }
    }
    
    func deleteFromCloudKit(_ item: Package) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await cloudKitHelper.delete(recordID: recordID, for: Package.self)
        } catch {
            print("❌ Failed to delete package from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func loadFromCloudKit() async {
        do {
            let records = try await cloudKitHelper.fetchRecords(ofType: "Package")
            
            await MainActor.run {
                for (_, result) in records {
                    switch result {
                    case .success(let record):
                        // Check if package already exists in SwiftData database
                        let packageId = UUID(uuidString: record.recordID.recordName) ?? UUID()
                        
                        // Query SwiftData directly to check for existing record
                        guard let context = modelContext else { continue }
                        
                        let descriptor = FetchDescriptor<Package>(
                            predicate: #Predicate<Package> { package in
                                package.id == packageId
                            }
                        )
                        
                        do {
                            let existingPackages = try context.fetch(descriptor)
                            if existingPackages.isEmpty {
                                // Find the department
                                var department: Department?
                                if let departmentRef = record["department"] as? CKRecord.Reference,
                                   let departmentId = UUID(uuidString: departmentRef.recordID.recordName) {
                                    department = DepartmentManager.shared.departments.first { $0.id == departmentId }
                                }
                                
                                if let department = department {
                                    // Only create if doesn't exist in database
                                    let package = Package(
                                        id: packageId,
                                        name: record["name"] as? String ?? "",
                                        department: department,
                                        descriptionText: record["descriptionText"] as? String
                                    )
                                    
                                    context.insert(package)
                                    try context.save()
                                    print("✅ Added new package from CloudKit: \(package.name)")
                                } else {
                                    print("⚠️ Skipping package - department not found: \(record["name"] as? String ?? "Unknown")")
                                }
                            } else {
                                print("ℹ️ Package already exists locally: \(record["name"] as? String ?? "Unknown")")
                            }
                        } catch {
                            print("❌ Failed to check/save package from CloudKit: \(error)")
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to download package: \(error.localizedDescription)")
                    }
                }
                loadPackages() // Refresh the packages array
            }
        } catch {
            print("❌ Failed to load packages from CloudKit: \(error.localizedDescription)")
        }
    }
    
    func syncAllToCloudKit() async {
        for package in packages {
            await syncToCloudKit(package)
        }
    }
}
