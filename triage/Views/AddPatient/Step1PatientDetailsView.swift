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
        VStack(spacing: 0) {
            
            // ====== Content Area ======
            if viewModel.inputMode == .paste {
                // --- Paste Mode ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Please fill in the patient’s details completely")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0F0E46"))
                        Spacer()
                        Button {
                            viewModel.clearInput()
                            viewModel.inputMode = .idCard
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Attach ID Card")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color(hex: "#F0F0F7"))
                            .foregroundColor(Color(hex: "#0F0E46"))
                            .cornerRadius(6)
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.rawText)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#F9F9F9")) // background fill
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#F9F9F9"), lineWidth: 1) // border
                            )
                            .frame(minHeight: 220)
                        
                        if viewModel.rawText.isEmpty {
                            Text("PASTE HERE")
                                .foregroundColor(Color(hex: "#0F0E46").opacity(0.4))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                        }
                    }
                }
                .padding()
                
            } else {
                // --- Upload Mode ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Please Attach Patient ID Card here")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0F0E46"))
                        Spacer()
                        Button {
                            viewModel.idCardImage = nil
                            viewModel.clearInput()
                            viewModel.inputMode = .paste
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Paste Text")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color(hex: "#F0F0F7"))
                            .foregroundColor(Color(hex: "#0F0E46"))
                            .cornerRadius(6)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(hex: "#F0F0F7"),
                                          style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .background(Color(hex: "#F0F0F7").opacity(0.3))
                        
                        VStack(spacing: 12) {
                            if viewModel.uploading {
                                ProgressView("Parsing ID Card...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#0F0E46")))
                                    .font(.subheadline)
                            } else if let image = viewModel.idCardImage {
                                // Show uploaded image preview
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 220)
                                    .cornerRadius(6)
                            } else {
                                // Default instructions
                                Text("Choose an image or drag/drop it here")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("JPEG, PNG up to 10 MB")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Browse + Clear buttons
                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    HStack {
                                        Image(systemName: "tray.and.arrow.down")
                                        Text(viewModel.idCardImage == nil ? "Browse Photos" : "Change Photo")
                                    }
                                    .font(.subheadline.bold())
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(Color(hex: "#0F0E46"))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                }
                                
                                if viewModel.idCardImage != nil {
                                    Button {
                                        viewModel.idCardImage = nil
                                        viewModel.clearInput()
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
                .padding()
                .onChange(of: selectedPhoto) { newItem in
                    if let newItem {
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
                }
            }
            
            Spacer()
                        
            // ===== Step Indicators at Bottom =====
            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { i in
                    HStack(spacing: 0) {
                       Circle()
                           .fill(i <= 1 ? Color(hex: "#0F0E46") : Color(hex: "#F0F0F7"))
                           .frame(width: 28, height: 28)
                           .overlay(
                               Text("\(i)")
                                   .foregroundColor(i <= 1 ? .white : .black)
                           )

                       // draw line except after the last circle
                       if i < 3 {
                           Rectangle()
                               .fill(Color(hex: "#F0F0F7"))
                               .frame(height: 2)
                               .frame(maxWidth: 28)
                       }
                   }
                }
            }
            .padding(.vertical, 20)
        }
    }
}



/*
 
Format Text
NIK: 12345567890123456
Nama lengkap: John Doe
DOB: 1 January 2000
Phone no: +6281234566789
Address: Emerald Lake, Citraland
 
 */
