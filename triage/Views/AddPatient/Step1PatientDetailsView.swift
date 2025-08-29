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
    @ObservedObject var viewModel: AddPatientViewModel
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
                    .foregroundColor(Color(hex: "#0F0E46"))
            }
            
            // --- Upload Mode ---
            UploadIDCardView(selectedPhoto: $selectedPhoto, idCardImage: $viewModel.idCardImage, uploading: $viewModel.uploading) {
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
                    viewModel.uploading = true
                    viewModel.parseIDCardFromImage(fileURL: tempURL)
                }
            }
        }
        .padding()
    }
}

// MARK: - Subviews

private struct PasteTextView: View {
    @Binding var rawText: String
    var clearAction: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Please fill in the Patient’s details")
                .font(.headline)
                .foregroundColor(Color(hex: "#0F0E46"))
            
            ZStack(alignment: .topLeading) {
                CustomTextEditor(text: $rawText)
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#F9F9F9"), lineWidth: 1)
                    )
                    .frame(minHeight: 220)
                    .focused($isFocused) // <-- attach focus here
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }
                
                if rawText.isEmpty {
                    Text("""
                    NIK:
                    Nama lengkap: 
                    Tgl lahir: 
                    No telp: 
                    Alamat lengkap: 
                    Jenis kelamin (L/P): 
                    """)
                    .foregroundColor(Color(hex: "#0F0E46").opacity(0.4))
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

private struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear  // Important!
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
    }
}

private struct UploadIDCardView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var idCardImage: UIImage?
    @Binding var uploading: Bool
    var clearAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Please attach Patient ID Card here")
                .font(.headline)
                .foregroundColor(Color(hex: "#0F0E46"))
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(hex: "#0F0E46"), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .background(Color(hex: "#F0F0F7").opacity(0.3))
                
                VStack(spacing: 12) {
                    if uploading {
                        ProgressView("Parsing ID Card...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#0F0E46")))
                            .font(.subheadline)
                    } else if let image = idCardImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .cornerRadius(6)
                    } else {
                        Text("Choose an image or drag/drop it here")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("JPEG, PNG up to 10 MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack {
                                Image(systemName: "tray.and.arrow.down")
                                Text(idCardImage == nil ? "Browse Photos" : "Change Photo")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color(hex: "#0F0E46"))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        
                        if idCardImage != nil {
                            Button {
                                idCardImage = nil
                                clearAction()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Clear")
                                }
                                .font(.subheadline.bold())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color(hex: "#F0F0F7"))
                                .foregroundColor(Color(hex: "#0F0E46"))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding()
            }
        }
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
