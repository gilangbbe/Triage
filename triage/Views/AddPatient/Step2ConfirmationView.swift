//
//  Step2ConfirmationView.swift
//  triage
//
//  Created by Chiquitta Kellie on 29/08/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct Step2ConfirmationView: View {
    @Bindable var viewModel: AddPatientViewModel
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            VStack {
                
                // === Left Side (same as Step 1) ===
                if viewModel.inputMode == .paste {
                    PasteTextView(rawText: $viewModel.rawText, isStep1: false) {
                        viewModel.clearInput()
                    }
                    .frame(maxWidth: 300) // keep width consistent
                    .padding()
                } else {
                    UploadIDCardView(selectedPhoto: $selectedPhoto,
                                     idCardImage: $viewModel.idCardImage,
                                     uploading: $viewModel.isUploading,
                                     isStep1: false) {
                        viewModel.clearInput()
                    }
                    .frame(maxWidth: 300)
                    .padding()
                }
                
//                Spacer();
            }
            
            // === Right Side (editable form) ===
            VStack(alignment: .leading, spacing: 16) {
                Text("Confirm Patient Information")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
                
                Group {
                    // NIK
                    CustomFormField(title: "National Identity Number", text: Binding(
                        get: { viewModel.nationalId ?? "" },
                        set: { viewModel.nationalId = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }
                    
                    // Full Name
                    CustomFormField(title: "Full Name", isRequired: true, text: $viewModel.fullName)
                    
                    // DOB
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date of Birth".uppercased())
                            .font(.caption)
                            .foregroundColor(Color("TextPrimary"))
                        DatePicker("", selection: Binding(
                            get: { viewModel.dateOfBirth ?? Date() },
                            set: { viewModel.dateOfBirth = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "en_GB"))
                    }
                    
                    // Phone
                    CustomFormField(title: "Phone Number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                    
                    // Address
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Address".uppercased())
                            .font(.caption)
                            .foregroundColor(Color("TextPrimary"))
                        TextEditor(text: $viewModel.address)
                            .frame(minHeight: 40, maxHeight: 100)
                            .padding(8)
                            .background(Color("BackgroundPrimary"))
                            .cornerRadius(6)
                            .scrollContentBackground(.hidden)
                    }

                    
                    // Gender
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gender".uppercased())
                            .font(.caption)
                            .foregroundColor(Color("TextPrimary"))
                        Picker("Gender", selection: Binding(
                            get: { viewModel.gender ?? .male },
                            set: { viewModel.gender = $0 }
                        )) {
                            Text("Laki-laki").tag(Gender.male)
                            Text("Perempuan").tag(Gender.female)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .padding()
        }
        .onChange(of: viewModel.idCardImage) { newImage in
            if newImage != nil {
                viewModel.inputMode = .idCard
            } else {
                viewModel.inputMode = .paste
            }
        }
        .onChange(of: selectedPhoto) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg") as URL? {
                    
                    try? data.write(to: tempURL)
                    viewModel.idCardImage = uiImage
                    viewModel.isUploading = true
                    viewModel.parseIDCardFromImage(fileURL: tempURL)
                }
            }
        }
    }
}

// Reusable text field
private struct CustomFormField: View {
    var title: String
    var isRequired: Bool = false
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text(title.uppercased())
                    .font(.caption)
                    .foregroundColor(Color("TextPrimary"))
                if isRequired {
                    Text("*").foregroundColor(.red)
                }
            }
            TextField("", text: $text)
                .padding(8)
                .background(Color("BackgroundPrimary"))
                .cornerRadius(6)
        }
    }
}
