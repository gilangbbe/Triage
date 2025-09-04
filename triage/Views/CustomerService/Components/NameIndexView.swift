//
//  NameIndexView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct NameIndexView: View {
    @Bindable var viewModel: PatientListViewModel
    var proxy: ScrollViewProxy
    
    // Always show A–Z
    let sectionTitles = (65...90).map { String(UnicodeScalar($0)!) }
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                ForEach(sectionTitles, id: \.self) { letter in
                    Button(action: {
                        withAnimation {
                            if viewModel.selectedLetter == letter {
                                // 👇 tapped the same letter again → reset filter
                                viewModel.selectedLetter = nil
                            } else {
                                viewModel.selectedLetter = letter
                                if let firstPatient = viewModel.filteredPatients.first(where: { $0.firstLetter == letter }) {
                                    proxy.scrollTo(firstPatient.id, anchor: .top)
                                }
                            }
                        }
                    }) {
                        Text(letter)
                            .font(.caption2)
                            .foregroundColor(viewModel.selectedLetter == letter ? .blue : .accentColor)
                            .padding(.vertical, 1)
                            .frame(width: 24, height: 20)
                    }
                    
                }
            }
            .background(Color.gray.opacity(0.1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("A-Z Index"))
            .accessibilityHint(Text("Scroll down to find a specific alhpabetic letter and Tap it to select the corresponding patient"))
        }
    }
}
