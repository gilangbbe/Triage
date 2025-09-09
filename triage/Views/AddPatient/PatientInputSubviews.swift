//
//  PatientInputSubviews.swift
//  triage
//
//  Created by Chiquitta Kellie on 30/08/25.
//

import SwiftUI
import PhotosUI

struct PasteTextView: View {
    @Binding var rawText: String
    var clearAction: () -> Void
    var isStep1: Bool = true
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isStep1 ? "Please fill in the Patient’s details" : "Pasted Data")
                .font(.headline)
                .foregroundColor(Color("TextPrimary").opacity(isStep1 ? 1 : 0.5))
            
            ZStack(alignment: .topLeading) {
                CustomTextEditor(text: $rawText)
                    .disabled(!isStep1)
                    .background(isStep1 ? Color("BackgroundPrimary") : Color("BackgroundPrimary"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isStep1 ? Color("BackgroundSecondary") : Color.black.opacity(0.2),
                                style: isStep1
                                    ? StrokeStyle(lineWidth: 1)
                                    : StrokeStyle(lineWidth: 1, dash: [4])
                            )
                    )
                    .frame(minHeight: 220)
                    .focused($isFocused)
                    .onAppear {
                        if isStep1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
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
                    .foregroundColor(Color("TextPrimary").opacity(isStep1 ? 0.4 : 0.2))
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
        }
    }
}


struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
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

struct UploadIDCardView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var idCardImage: UIImage?
    @Binding var uploading: Bool
    var clearAction: () -> Void
    var isStep1: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isStep1 ? "Please attach Patient ID Card here" : "Uploaded Data")
                .font(.headline)
                .foregroundColor(Color("TextPrimary").opacity(isStep1 ? 1 : 0.5))
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isStep1 ? Color("TextPrimary") : Color.black.opacity(0.2),
                                  style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .background(isStep1 ? Color("BackgroundSecondary")
                                        : Color("BackgroundPrimary").opacity(0.5))
                
                VStack(spacing: 12) {
                    if uploading {
                        ProgressView("Parsing ID Card...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("TextPrimary")))
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
                            .foregroundColor(isStep1 ? Color("TextPrimary") : .secondary)
                        Text("JPEG, PNG up to 10 MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if isStep1 {
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                HStack {
                                    Image(systemName: "tray.and.arrow.down")
                                    Text(idCardImage == nil ? "Browse Photos" : "Change Photo")
                                }
                                .font(.subheadline.bold())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color("TextPrimary"))
                                .foregroundColor(Color("ButtonPrimary"))
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
                                    .background(Color("BackgroundSecondary"))
                                    .foregroundColor(Color("TextPrimary"))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .opacity(isStep1 ? 1 : 0.95)
    }
}
