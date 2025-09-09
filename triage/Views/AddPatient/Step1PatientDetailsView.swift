//
//  Step1PatientDetailsView.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct Step1PatientDetailsView: View {
    @Bindable var viewModel: AddPatientViewModel
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    var body: some View {
        HStack {
            // --- Paste Mode ---
            if viewModel.inputMode == .paste {
                PasteTextView(rawText: $viewModel.rawText) {
                    viewModel.clearInput()
                }
                .padding()
                
                Text("or")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            // --- Upload Mode ---
            UploadIDCardView(selectedPhoto: $selectedPhoto, idCardImage: $viewModel.idCardImage, uploading: $viewModel.isUploading) {
                viewModel.clearInput()
            }
            .padding()
        }
        .onChange(of: viewModel.idCardImage) { newImage in
            // switch input mode automatically
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
        .padding()
    }
}

/*
 
Format Text
NIK: 12345567890123456
Nama lengkap: John Doe
Tgl lahir: 1 January 2000
No telp: +6281234566789
Alamat lengkap: Emerald Lake, Citraland
Jenis kelamin (L/P): L

 */
