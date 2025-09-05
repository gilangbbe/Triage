//
//  AddDepartmentView.swift
//  triage
//
//  Created by Assistant on 05/09/25.
//

import SwiftUI

struct AddDepartmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DepartmentManager.self) private var departmentManager
    
    @State private var name = ""
    @State private var maxSlot = 3
    
    let onDepartmentCreated: ((Department) -> Void)?
    
    init(onDepartmentCreated: ((Department) -> Void)? = nil) {
        self.onDepartmentCreated = onDepartmentCreated
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Department Details") {
                    TextField("Department Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Stepper("Max slots per hour: \(maxSlot)", value: $maxSlot, in: 1...10)
                }
                
                Section(footer: Text("Create a department to organize medical service packages.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Department")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDepartment()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveDepartment() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newDepartment = Department(name: trimmedName, maxSlot: maxSlot)
        
        departmentManager.addDepartment(newDepartment)
        onDepartmentCreated?(newDepartment)
        dismiss()
    }
}

#Preview {
    AddDepartmentView()
        .environment(DepartmentManager.shared)
}
