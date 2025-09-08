//
//  AddPackageView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI
import SwiftData

struct AddPackageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PackageManager.self) private var packageManager
    
    @State private var name = ""
    @State private var descriptionText = ""
    
    // Pre-selected department (required - only shown when adding from department)
    let department: Department
    
    init(department: Department) {
        self.department = department
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Package Details") {
                    TextField("Package Name", text: $name)
                    
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section("Department") {
                    HStack {
                        Text(department.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Max \(department.maxSlot ?? 3) slots/hour")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(footer: Text("This package will be added to the \(department.name) department.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Package")
            .navigationBarTitleDisplayMode(.inline)
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
            department: department,
            descriptionText: descriptionText.isEmpty ? nil : descriptionText
        )
        
        packageManager.addPackage(newPackage)
        dismiss()
    }
}

#Preview {
    // Create a sample department for preview
    let sampleDepartment = Department(name: "Medical Check Up", maxSlot: 5)
    
    AddPackageView(department: sampleDepartment)
        .environment(PackageManager.shared)
}
