//
//  PackageListViewModel.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import Foundation
import SwiftUI

@Observable
class PackageListViewModel {
    var searchText = ""
    var showingAddPackage = false
    
    private let packageManager: PackageManager
    
    init(packageManager: PackageManager) {
        self.packageManager = packageManager
    }
    
    var filteredPackages: [Package] {
        if searchText.isEmpty {
            return packageManager.packages
        } else {
            return packageManager.searchPackages(query: searchText)
        }
    }
    
    func addPackage(_ package: Package) {
        packageManager.addPackage(package)
    }
    
    func deletePackage(_ package: Package) {
        packageManager.deletePackage(package)
    }
    
    func deletePackages(at indexSet: IndexSet, from packages: [Package]) {
        for index in indexSet {
            let package = packages[index]
            packageManager.deletePackage(package)
        }
    }
    
    func assignPackageToPatient(_ package: Package, patient: Patient) {
        packageManager.assignPackageToPatient(package, patient: patient)
    }
    
    func removePackageFromPatient(_ package: Package, patient: Patient) {
        packageManager.removePackageFromPatient(package, patient: patient)
    }
    
    func packagesForPatient(_ patient: Patient) -> [Package] {
        return packageManager.packagesForPatient(patient)
    }
}
