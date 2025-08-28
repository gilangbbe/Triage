//
//  AddPackageView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct AddPackageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PackageManager.self) private var packageManager
    
    @State private var name = ""
    @State private var descriptionText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Package Details") {
                    TextField("Package Name", text: $name)
                    
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section(footer: Text("Create a medical service package that can be assigned to patients.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Package")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePackage()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func savePackage() {
        let newPackage = Package(
            name: name,
            descriptionText: descriptionText.isEmpty ? nil : descriptionText
        )
        
        packageManager.addPackage(newPackage)
        dismiss()
    }
}

#Preview {
    AddPackageView()
        .environment(PackageManager.shared)
}
