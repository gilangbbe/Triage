//
//  AddPatientView.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: AddPatientViewModel.ValidationStep = .dataInput
    @State private var viewModel: AddPatientViewModel
    var historyViewModel: HistoryViewModel
    
    init(patientManager: PatientManager, appointmentManager: AppointmentManager, packageManager: PackageManager, historyViewModel: HistoryViewModel) {
        _viewModel = State(wrappedValue: AddPatientViewModel(
            patientManager: patientManager,
            appointmentManager: appointmentManager,
            packageManager: packageManager,
        ))
        self.historyViewModel = historyViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CurrentStepView(viewModel: viewModel, currentStep: currentStep)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(currentStep == .dataInput ? "Cancel" : "Back") {
                        handleBackAction()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    StepIndicatorView(currentStep: currentStep)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NextButton(
                        viewModel: viewModel,
                        currentStep: currentStep,
                        historyViewModel: historyViewModel,
                        onNext: handleNextAction,
                        onSave: handleSaveAction
                    )
                }
            }
        }
    }
    
    // MARK: - Actions
    private func handleBackAction() {
        if currentStep == .dataInput {
            dismiss()
        } else {
            withAnimation {
                currentStep = AddPatientViewModel.ValidationStep(rawValue: currentStep.rawValue - 1) ?? .dataInput
            }
        }
    }
    
    private func handleNextAction() {
        if currentStep == .dataInput {
            viewModel.parseFromRawText()
        }
        
        withAnimation {
            currentStep = AddPatientViewModel.ValidationStep(rawValue: currentStep.rawValue + 1) ?? .appointments
        }
    }
    
    private func handleSaveAction() {
        viewModel.savePatient()
        dismiss()
    }
}

// MARK: - Supporting Views
struct CurrentStepView: View {
    let viewModel: AddPatientViewModel
    let currentStep: AddPatientViewModel.ValidationStep
    
    var body: some View {
        switch currentStep {
        case .dataInput:
            Step1PatientDetailsView(viewModel: viewModel)
        case .confirmation:
            Step2ConfirmationView(viewModel: viewModel)
        case .appointments:
            Step3AppointmentsView(viewModel: viewModel)
        }
    }
}

struct StepIndicatorView: View {
    let currentStep: AddPatientViewModel.ValidationStep
    
    var body: some View {
        VStack(alignment: .center) {
            Text("STEP \(currentStep.rawValue) OF 3")
                .font(.caption)
                .foregroundColor(Color("TextSecondary"))
            Text("New Patient")
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
        }
    }
}

struct NextButton: View {
    let viewModel: AddPatientViewModel
    let currentStep: AddPatientViewModel.ValidationStep
    let historyViewModel: HistoryViewModel
    let onNext: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        if currentStep != .appointments {
            Button("Next") {
                onNext()
            }
            .disabled(!viewModel.isStepValid(currentStep))
        } else {
            Button("Add") {
                onSave()
                recordNewPatient(patientName: viewModel.fullName)
            }
            .disabled(!viewModel.isFormComplete)
        }
    }
    
    private func recordNewPatient(patientName: String) {
        let log = History(
            type: .newPatient(patientName: patientName)
        )
        print(log)
        historyViewModel.addHistory(log)
    }
}

