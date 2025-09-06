//
//  HealthCareCatalogView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct HealthCareCatalogView: View {
    @Environment(PackageManager.self) private var packageManager
    @Environment(DepartmentManager.self) private var departmentManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var showingAddDepartment = false
    @State private var selectedDepartmentForPackage: Department? = nil
    @State private var editingDepartment: Department? = nil
    
    // Computed property for sheet presentation
    private var showingAddPackage: Binding<Bool> {
        Binding(
            get: { selectedDepartmentForPackage != nil },
            set: { if !$0 { selectedDepartmentForPackage = nil } }
        )
    }
    
    // Group packages by department
    private var groupedPackages: [String: [Package]] {
        let filteredPackages = searchText.isEmpty ? 
            packageManager.packages : 
            packageManager.searchPackages(query: searchText)
        
        return Dictionary(grouping: filteredPackages) { package in
            package.department.name
        }
    }
    
    // Get all departments (including those without packages)
    private var allDepartments: [Department] {
        return departmentManager.departments.sorted { $0.name < $1.name }
    }
    
    // Department categories with their display names and colors
    private let departmentConfig: [String: (displayName: String, color: Color)] = [
        "Medical Check Up": ("MEDICAL CHECK UP", Color.blue.opacity(0.1)),
        "Radiology": ("RADIOLOGY", Color.green.opacity(0.1)), 
        "Laboratory": ("LABORATORY", Color.red.opacity(0.1))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Title + Search + Add Department
            HStack {
                Text("Healthcare Catalog & Department Management")
                    .font(.headline)
                    .foregroundColor(Color.accent)
                
                Spacer()
                
                // Add Department Button
                Button("+ Department") {
                    showingAddDepartment = true
                }
                .foregroundColor(Color.accent)
                .font(.subheadline)
                
                HStack {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    
                    Button(action: {
                        // Search is automatic through searchText binding
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Display all departments (including empty ones)
                    ForEach(allDepartments, id: \.id) { department in
                        let packages = groupedPackages[department.name] ?? []
                        let config = departmentConfig[department.name] ?? (department.name.uppercased(), Color.purple.opacity(0.1))
                        
                        DepartmentSectionView(
                            department: department,
                            displayTitle: config.displayName,
                            packages: packages,
                            color: config.color,
                            onAddPackage: {
                                selectedDepartmentForPackage = department
                            },
                            onEditDepartment: {
                                editingDepartment = department
                            },
                            onDeleteDepartment: {
                                departmentManager.deleteDepartment(department)
                            },
                            onDeletePackage: { package in
                                packageManager.deletePackage(package)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            packageManager.setModelContext(modelContext)
            departmentManager.setModelContext(modelContext)
        }
        .sheet(isPresented: showingAddPackage) {
            if let department = selectedDepartmentForPackage {
                AddPackageView(department: department)
            }
        }
        .sheet(isPresented: $showingAddDepartment) {
            AddDepartmentView()
        }
        .sheet(item: $editingDepartment) { department in
            EditDepartmentView(department: department)
        }
    }
}

// MARK: - Edit Department View
struct EditDepartmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DepartmentManager.self) private var departmentManager
    
    let department: Department
    
    @State private var name: String
    @State private var maxSlot: Int
    @State private var showingDeleteAlert = false
    
    init(department: Department) {
        self.department = department
        _name = State(initialValue: department.name)
        _maxSlot = State(initialValue: department.maxSlot ?? 3)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Department Details") {
                    TextField("Department Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Stepper("Max slots per hour: \(maxSlot)", value: $maxSlot, in: 1...10)
                }
                
                Section {
                    Button("Delete Department", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
                
                Section(footer: Text("Changes will affect all packages in this department.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Edit Department")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Department", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    departmentManager.deleteDepartment(department)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete '\(department.name)' department? This will also delete all packages and cancel related appointments. This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        department.name = trimmedName
        department.maxSlot = maxSlot
        
        departmentManager.updateDepartment(department)
        dismiss()
    }
}

struct DepartmentSectionView: View {
    let department: Department
    let displayTitle: String
    let packages: [Package]
    let color: Color
    let onAddPackage: () -> Void
    let onEditDepartment: () -> Void
    let onDeleteDepartment: () -> Void
    let onDeletePackage: (Package) -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Text("Max \(department.maxSlot ?? 3) slots/hour")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("+ Package") {
                        onAddPackage()
                    }
                    .foregroundColor(Color.accent)
                    .font(.subheadline)
                    
                    Menu {
                        Button("Edit Department") {
                            onEditDepartment()
                        }
                        
                        Button("Delete Department", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if packages.isEmpty {
                    Text("No packages in this department")
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                } else {
                    ForEach(packages, id: \.id) { package in
                        PackageRowView(
                            package: package,
                            onDelete: {
                                onDeletePackage(package)
                            }
                        )
                        
                        if package.id != packages.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .background(color)
            .cornerRadius(8)
        }
        .alert("Delete Department", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteDepartment()
            }
        } message: {
            if packages.isEmpty {
                Text("Are you sure you want to delete '\(department.name)' department? This action cannot be undone.")
            } else {
                Text("Are you sure you want to delete '\(department.name)' department? This will also delete \(packages.count) package(s) and cancel all related appointments. This action cannot be undone.")
            }
        }
    }
}

// Keep the original SectionView for backward compatibility if needed
struct SectionView: View {
    let title: String
    let packages: [Package]
    let color: Color
    let onAdd: () -> Void
    let onDelete: (Package) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("Add") {
                    onAdd()
                }
                .foregroundColor(Color.accent)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if packages.isEmpty {
                    Text("No packages in this category")
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                } else {
                    ForEach(packages, id: \.id) { package in
                        PackageRowView(
                            package: package,
                            onDelete: {
                                onDelete(package)
                            }
                        )
                        
                        if package.id != packages.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .background(color)
            .cornerRadius(8)
        }
    }
}

struct PackageRowView: View {
    let package: Package
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(package.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let description = package.descriptionText, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Show appointment count if there are any
                if !package.appointments.isEmpty {
                    Text("\(package.appointments.count) appointment(s) scheduled")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .alert("Delete Package", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            if package.appointments.isEmpty {
                Text("Are you sure you want to delete '\(package.name)'? This action cannot be undone.")
            } else {
                Text("Are you sure you want to delete '\(package.name)'? This will also cancel \(package.appointments.count) scheduled appointment(s). This action cannot be undone.")
            }
        }
    }
}

#Preview {
    HealthCareCatalogView()
        .environment(PackageManager.shared)
        .environment(DepartmentManager.shared)
}
