//
//  PackageListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct PackageListView: View {
    @Environment(PackageListViewModel.self) private var viewModel
    @State private var showingAddPackage = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredPackages, id: \.id) { package in
                    PackageRowView(package: package)
                }
                .onDelete { indexSet in
                    viewModel.deletePackages(at: indexSet, from: viewModel.filteredPackages)
                }
            }
            .navigationTitle("Packages")
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                viewModel.searchText = newValue
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Package") {
                        showingAddPackage = true
                    }
                }
            }
            .sheet(isPresented: $showingAddPackage) {
                AddPackageView()
            }
        }
    }
}

struct PackageRowView: View {
    let package: Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(package.name)
                .font(.headline)
            
            if let description = package.descriptionText {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("\(package.patients.count)", systemImage: "person.3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !package.patients.isEmpty {
                    Text("Assigned Patients")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PackageListView()
        .environment(PackageListViewModel(packageManager: PackageManager.shared))
}
