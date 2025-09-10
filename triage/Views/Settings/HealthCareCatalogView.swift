//
//  HealthCareCatalogView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

// MARK: - Healthcare Catalog
struct HealthCareCatalogView: View {
    @Environment(PackageManager.self) private var packageManager
    @Environment(DepartmentManager.self) private var departmentManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var showingAddDepartment = false
    @State private var selectedDepartmentForPackage: Department? = nil
    @State private var editingDepartment: Department? = nil
    
    private var showingAddPackage: Binding<Bool> {
        Binding(
            get: { selectedDepartmentForPackage != nil },
            set: { if !$0 { selectedDepartmentForPackage = nil } }
        )
    }
    
    private var groupedPackages: [String: [Package]] {
        let filteredPackages = searchText.isEmpty ? 
            packageManager.packages : 
            packageManager.searchPackages(query: searchText)
        
        return Dictionary(grouping: filteredPackages) { package in
            package.department?.name ?? "Unknown Department"
        }
    }
    private var allDepartments: [Department] {
        departmentManager.departments.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search + Add
            HStack(spacing: 12) {
                Text("Setting Up the Healthcare Catalog")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                SearchField(text: $searchText, placeholder: "Search")
                    .frame(width: 200)
                Button {
                    showingAddDepartment = true
                } label: {
                    Text("Add Department")
                        .font(.footnote)
                        .foregroundStyle(Color("TextPrimary"))
                }
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(allDepartments, id: \.id) { dept in
                        let packages = groupedPackages[dept.name] ?? []
                        DepartmentSectionView(
                            department: dept,
                            displayTitle: dept.name.uppercased(),
                            packages: packages,
                            color: Color("BackgroundSettings"),
                            onAddPackage: { selectedDepartmentForPackage = dept },
                            onEditDepartment: { editingDepartment = dept },
                            onDeleteDepartment: { departmentManager.deleteDepartment(dept) },
                            onDeletePackage: { packageManager.deletePackage($0) }
                        )
                    }
                }
            }
        }
        .padding([.top, .leading, .trailing], 16)
        .background(Color(.systemBackground))
        .onAppear {
            packageManager.setModelContext(modelContext)
            departmentManager.setModelContext(modelContext)
        }
        .sheet(isPresented: showingAddPackage) {
            if let dept = selectedDepartmentForPackage {
                AddPackageView(department: dept)
            }
        }
        .sheet(isPresented: $showingAddDepartment) { AddDepartmentView() }
        .sheet(item: $editingDepartment) { EditDepartmentView(department: $0) }
    }
}

// MARK: - SearchField
struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "999999"))
            
            TextField(placeholder, text: $text)
                .font(.subheadline)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color("SearchBackground"))
        )
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
                Text(displayTitle)
                    .font(.footnote)
                    .foregroundColor(Color("TextPrimary").opacity(0.8))
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Add") {
                        onAddPackage()
                    }
                    .foregroundColor(Color("TextPrimary"))
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
                        .frame(maxWidth: .infinity, alignment: .center)
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
                        .frame(maxWidth: .infinity, alignment: .center)
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
                if let appointments = package.appointments, !appointments.isEmpty {
                    Text("\(appointments.count) appointment(s) scheduled")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                }
//                if !package.appointments.isEmpty {
//                    Text("\(package.appointments.count) appointment(s) scheduled")
//                        .font(.caption2)
//                        .foregroundColor(.orange)
//                        .padding(.top, 2)
//                }
            }
            
            Spacer()
            
            Button(action: {
                showingDeleteAlert = true
            }) {
                Text("Delete")
                    .font(.caption)
                    .foregroundColor(Color("OutlineDelete"))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .alert("Delete Package", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            let appointmentCount = package.appointments?.count ?? 0
            if appointmentCount == 0 {
                Text("Are you sure you want to delete '\(package.name)'? This action cannot be undone.")
            } else {
                Text("Are you sure you want to delete '\(package.name)'? This will also cancel \(appointmentCount) scheduled appointment(s). This action cannot be undone.")
            }
        }
    }
}

#Preview {
    HealthCareCatalogView()
        .environment(PackageManager.shared)
        .environment(DepartmentManager.shared)
}
