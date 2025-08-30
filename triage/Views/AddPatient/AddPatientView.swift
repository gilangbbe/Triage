//
//  AddPatientView.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step = 1
    @StateObject private var viewModel = AddPatientViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                switch step {
                case 1: Step1PatientDetailsView(viewModel: viewModel)
                case 2: Step2ConfirmationView(viewModel: viewModel)
                case 3: Step3AppointmentsView(viewModel: viewModel)
                default: EmptyView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(step == 1 ? "Cancel" : "Back") {
                       if step == 1 {
                           dismiss()
                       } else {
                           step -= 1
                       }
                   }
                }
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center) {
                        Text("STEP \(step) OF 3")
                            .font(.caption)
                            .foregroundColor(Color.black)
                        Text("New Patient")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0F0E46"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if step < 3 {
                        Button("Next") {
                            if step == 1 {
                                viewModel.parseFromRawText()
                                print(viewModel.isValidAll)
                            }
                            step += 1
                        }
                        .disabled(!viewModel.isStepValid(step))
                        
                    } else {
                        Button("Add") {
                            viewModel.savePatient()
                            dismiss()
                        }
                        .disabled(!viewModel.isValidAll)
                    }
                }

            }
        }
    }
}

