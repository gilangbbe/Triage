//
//  PackageListView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 28/08/25.
//

import SwiftUI

struct PackageListView: View {
    @Environment(PackageManager.self) private var packageManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(packageManager.packages, id: \.id) { package in
                    PackageRowView(package: package)
                }
                .onDelete { indexSet in
                    packageManager.deletePackages(at: indexSet)
                }
            }
            .navigationTitle("Packages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Package") {
                        // Add package action
                    }
                }
            }
        }
    }
}

struct PackageRowView: View {
    let package: Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(package.name)
                .font(.headline)
            
            if let description = package.descriptionText {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Text("\(package.patients.count) patients assigned")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PackageListView()
        .environment(PackageManager.shared)
}
