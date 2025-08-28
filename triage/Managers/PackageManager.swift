//
//  PackageManager.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftData
import Combine

@Observable
class PackageManager {
    static let shared = PackageManager()
    
    var packages: [Package] = []
    private var modelContext: ModelContext?
    
    private init() {
        loadPackages()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadPackages()
    }
    
    // MARK: - CRUD Operations
    func addPackage(_ package: Package) {
        guard let context = modelContext else { return }
        
        context.insert(package)
        saveContext()
        loadPackages()
    }
    
    func updatePackage(_ package: Package) {
        saveContext()
        loadPackages()
    }
    
    func deletePackage(_ package: Package) {
        guard let context = modelContext else { return }
        
        context.delete(package)
        saveContext()
        loadPackages()
    }
    
    func deletePackages(at indexSet: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in indexSet {
            let package = packages[index]
            context.delete(package)
        }
        saveContext()
        loadPackages()
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
        if !package.patients.contains(where: { $0.id == patient.id }) {
            package.patients.append(patient)
            saveContext()
            loadPackages()
        }
    }
    
    func removePackageFromPatient(_ package: Package, patient: Patient) {
        package.patients.removeAll { $0.id == patient.id }
        saveContext()
        loadPackages()
    }
    
    func packagesForPatient(_ patient: Patient) -> [Package] {
        return packages.filter { package in
            package.patients.contains { $0.id == patient.id }
        }
    }
}
