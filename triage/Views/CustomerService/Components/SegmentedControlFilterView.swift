//
//  SegmentedControlFilterView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct SegmentedControlFilterView: View {
    @State private var selectedSegment = 0
    
    var body : some View {
        VStack {
            Picker("Select Service", selection: $selectedSegment) {
                Text("MCU").tag(0)
                Text("Radiology").tag(1)
                Text("Laboratorium").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 18)
        }
    }
}
