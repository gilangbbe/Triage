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
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var descriptionText = ""
    @State private var departmentName = ""
    @State private var departmentMaxSlot = 3
    @State private var selectedDepartment: Department?
    @State private var availableDepartments: [Department] = []
    @State private var showingDepartmentPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Package Details") {
                    TextField("Package Name", text: $name)
                    
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section("Department") {
                    if let selectedDepartment = selectedDepartment {
                        HStack {
                            Text(selectedDepartment.name)
                            Spacer()
                            Button("Change") {
                                showingDepartmentPicker = true
                            }
                            .foregroundColor(.blue)
                        }
                    } else {
                        Button("Select Department") {
                            showingDepartmentPicker = true
                        }
                    }
                    
                    TextField("Or create new department", text: $departmentName)
                        .disabled(selectedDepartment != nil)
                    
                    if !departmentName.isEmpty && selectedDepartment == nil {
                        Stepper("Max slots per hour: \(departmentMaxSlot)", value: $departmentMaxSlot, in: 1...10)
                    }
                }
                
                Section(footer: Text("Create a medical service package that can be assigned to patients.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Package")
            .onAppear {
                loadDepartments()
            }
            .sheet(isPresented: $showingDepartmentPicker) {
                DepartmentPickerView(departments: availableDepartments, selectedDepartment: $selectedDepartment)
            }
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
                    .disabled(name.isEmpty || (selectedDepartment == nil && departmentName.isEmpty))
                }
            }
        }
    }
    
    private func savePackage() {
        let department: Department
        
        if let selectedDepartment = selectedDepartment {
            department = selectedDepartment
        } else {
            // Create a new department
            department = Department(name: departmentName, maxSlot: departmentMaxSlot)
            modelContext.insert(department)
        }
        
        let newPackage = Package(
            name: name,
            department: department,
            descriptionText: descriptionText.isEmpty ? nil : descriptionText
        )
        
        packageManager.addPackage(newPackage)
        dismiss()
    }
    
    private func loadDepartments() {
        do {
            let descriptor = FetchDescriptor<Department>(
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            availableDepartments = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch departments: \(error)")
            availableDepartments = []
        }
    }
}

struct DepartmentPickerView: View {
    let departments: [Department]
    @Binding var selectedDepartment: Department?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(departments) { department in
                Button(action: {
                    selectedDepartment = department
                    dismiss()
                }) {
                    HStack {
                        Text(department.name)
                        Spacer()
                        if selectedDepartment?.id == department.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Department")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddPackageView()
        .environment(PackageManager.shared)
}
