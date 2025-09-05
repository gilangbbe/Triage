//
//  HealthCareCatalogView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct HealthCareCatalogView: View {
    @State private var searchText: String = ""
    
    // Placeholder data
    let medicalCheckup = ["Paket Merdeka Lite", "Paket Merdeka Pro", "EKG (Jantung)", "Basic", "Paket Merdeka Lite", "Paket Merdeka Lite"]
    let radiology = ["Paket Merdeka Lite", "Paket Merdeka Pro", "EKG (Jantung)", "Basic", "Paket Merdeka Lite", "Paket Merdeka Lite"]
    let laboratory = ["Paket Merdeka Lite", "Paket Merdeka Pro", "EKG (Jantung)", "Basic", "Paket Merdeka Lite", "Paket Merdeka Lite"]
    
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
                        .frame(width: 200) // adjust as needed
                    
                    Button(action: {
                        // Add search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    SectionView(title: "MEDICAL CHECK UP",
                                items: medicalCheckup,
                                color: Color.blue.opacity(0.1))
                    
                    SectionView(title: "RADIOLOGY",
                                items: radiology,
                                color: Color.green.opacity(0.1))
                    
                    SectionView(title: "LABORATORIUM",
                                items: laboratory,
                                color: Color.red.opacity(0.1))
                }
            }
        }
        .padding()
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("Add") {
                    // Add action
                }
                .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    
                    if item != items.last {
                        Divider()
                    }
                }
            }
            .background(color)
            .cornerRadius(8)
        }
    }
}

#Preview {
    HealthCareCatalogView()
}
