//
//  HealthCareCatalogView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct HealthCareCatalogView: View {
    @Environment(PackageManager.self) private var packageManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var showingAddPackage = false
    @State private var selectedDepartment: String? = nil
    
    // Group packages by department
    private var groupedPackages: [String: [Package]] {
        let filteredPackages = searchText.isEmpty ? 
            packageManager.packages : 
            packageManager.searchPackages(query: searchText)
        
        return Dictionary(grouping: filteredPackages) { package in
            package.department.name
        }
    }
    
    // Department categories with their display names
    private let departmentCategories = [
        "Medical Check Up": "MEDICAL CHECK UP",
        "Radiology": "RADIOLOGY", 
        "Laboratory": "LABORATORIUM"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Title + Search side by side
            HStack {
                Text("Setting Up the Healthcare Catalog")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#0F0E46"))
                
                Spacer()
                
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
                    // Display packages grouped by department
                    ForEach(Array(departmentCategories.keys.sorted()), id: \.self) { departmentKey in
                        let displayTitle = departmentCategories[departmentKey] ?? departmentKey.uppercased()
                        let packages = groupedPackages[departmentKey] ?? []
                        let color = colorForDepartment(departmentKey)
                        
                        SectionView(
                            title: displayTitle,
                            packages: packages,
                            color: color,
                            onAdd: {
                                selectedDepartment = departmentKey
                                showingAddPackage = true
                            },
                            onDelete: { package in
                                packageManager.deletePackage(package)
                            }
                        )
                    }
                    
                    // Show other departments that don't match predefined categories
                    let otherDepartments = groupedPackages.keys.filter { !departmentCategories.keys.contains($0) }
                    ForEach(Array(otherDepartments.sorted()), id: \.self) { departmentName in
                        let packages = groupedPackages[departmentName] ?? []
                        
                        SectionView(
                            title: departmentName.uppercased(),
                            packages: packages,
                            color: Color.purple.opacity(0.1),
                            onAdd: {
                                selectedDepartment = departmentName
                                showingAddPackage = true
                            },
                            onDelete: { package in
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
        }
        .sheet(isPresented: $showingAddPackage) {
            AddPackageView()
                .onDisappear {
                    selectedDepartment = nil
                }
        }
    }
    
    // Helper function to get color for each department
    private func colorForDepartment(_ department: String) -> Color {
        switch department {
        case "Medical Check Up":
            return Color.blue.opacity(0.1)
        case "Radiology":
            return Color.green.opacity(0.1)
        case "Laboratory":
            return Color.red.opacity(0.1)
        default:
            return Color.purple.opacity(0.1)
        }
    }
}

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
                .foregroundColor(.blue)
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
}
