//
//  SegmentedControlFilterView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct SegmentedControlFilterView: View {
    @Binding var selectedSegment: Int
    
    let departments = ["MCU", "Radiology", "Laboratory"]
    
    var body : some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(1...departments.count, id: \.self) { index in
                    Button(action: {
                        // Toggle behavior: if same segment is tapped, deselect (show all)
                        if selectedSegment == index {
                            selectedSegment = 0 // 0 means "All" (no filter)
                        } else {
                            selectedSegment = index
                        }
                    }) {
                        Text(departments[index - 1])
                            .font(.subheadline)
                            .foregroundColor(selectedSegment == index ? Color("ButtonPrimary") : Color("TextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedSegment == index ? Color("TextPrimary") : Color("BackgroundSettings"))
                    }
                    .contentShape(Rectangle())
                }
            }
            .background(Color(.systemGray5))
            .cornerRadius(8)
            .padding(.horizontal, 18)
        }
    }
}
