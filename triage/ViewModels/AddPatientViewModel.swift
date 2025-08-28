//
//  AddPatientViewModel.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//

import SwiftUI
import Vision
import UIKit


final class AddPatientViewModel: ObservableObject {
    enum InputMode {
        case paste
        case idCard
    }
    
    // Step 1
    @Published var rawText: String = ""          // pasted text or OCR result
    @Published var nik: String = ""
    @Published var name: String = ""
    @Published var dobString: String = ""        // "1 January 2000" as parsed
    @Published var phoneNumber: String = ""
    @Published var address: String = ""
    @Published var uploading: Bool = false       // OCR parsing running
    @Published var uploadCompleted: Bool = false // OCR finished (true when OCR has produced text)
    @Published var inputMode: InputMode = .paste
    @Published var didParseStep1: Bool = false   // true after parseFromRawText sets fields
    @Published var idCardImage: UIImage? = nil

    
    // Step 2 (kept for context)
    @Published var selectedCategory = "all"
    @Published var selectedAppointments: [Appointment] = []
    @Published var appointmentDates: [UUID: Date] = [:]
    @Published var needsConsultation: [UUID: Bool] = [:]
    
    var filteredPackets: [AppointmentPacket] { [] } // TODO
    
    // MARK: - validations
    func isStepValid(_ step: Int) -> Bool {
        switch step {
        case 1:
            // Next allowed if user pasted text OR OCR has completed (rawText set)
            return !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploadCompleted
        case 2:
            return !selectedAppointments.isEmpty
        default:
            return true
        }
    }
    
    var isValidAll: Bool {
        isStepValid(1) && isStepValid(2)
    }
    
    // MARK: - Parsing utility (regex capture group)
    private func value(for key: String, in text: String) -> String {
        // Match "key:" or "key :" ignoring case
        let pattern = "(?i)\(key)\\s*[:：]\\s*(.*)"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)) {
                return nsText.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
    
    // MARK: - Parse pasted / OCR text into fields
    func parseFromRawText() {
        let s = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else {
            didParseStep1 = false
            return
        }
        
        // First, try your structured format
        var nikVal = value(for: "NIK", in: s)
        var nameVal = value(for: "Nama lengkap", in: s)
        var dobVal = value(for: "DOB", in: s)
        var phoneVal = value(for: "Phone no", in: s)
        var addressVal = value(for: "Address", in: s)
        
        // If those are empty, fall back to OCR (KTP) style
        if nameVal.isEmpty {
            nameVal = value(for: "Nama", in: s)
        }
        if dobVal.isEmpty {
            // OCR shows "Tempat/Tgl Lahir"
            let tempDob = value(for: "Tempat/Tgl Lahir", in: s)
            if let commaIdx = tempDob.firstIndex(of: ",") {
                dobVal = String(tempDob[tempDob.index(after: commaIdx)...]).trimmingCharacters(in: .whitespaces)
            } else {
                dobVal = tempDob
            }
        }
        if addressVal.isEmpty {
            // KTP-style address = "Alamat" + RT/RW + Kel/Desa + Kecamatan
            let baseAddr = value(for: "Alamat", in: s)
            let rtRw = value(for: "RT/RW", in: s)
            let kel = value(for: "Kel/Desa", in: s)
            let kec = value(for: "Kecamatan", in: s)
            addressVal = [baseAddr, rtRw, kel, kec]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        }
        
        // Assign
        nik = nikVal
        name = nameVal
        dobString = dobVal
        phoneNumber = phoneVal
        address = addressVal
        
        didParseStep1 = !(nik.isEmpty && name.isEmpty)
        
        print("[AddPatientViewModel] parseFromRawText -> nik:\(nik) name:\(name) dob:\(dobString) phone:\(phoneNumber) address:\(address)")
    }

    
    // MARK: - OCR from image (does NOT persist the file; only reads)
    func parseIDCardFromImage(fileURL: URL) {
        uploading = true
        uploadCompleted = false
        didParseStep1 = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            defer {
                // ensure UI update runs on main
                DispatchQueue.main.async {
                    self.uploading = false
                }
            }
            
            guard let data = try? Data(contentsOf: fileURL),
                  let uiImage = UIImage(data: data),
                  let cgImage = uiImage.cgImage else {
                DispatchQueue.main.async {
                    self.uploadCompleted = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.idCardImage = uiImage
            }
            
            let request = VNRecognizeTextRequest { request, error in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    let textLines = observations.compactMap { $0.topCandidates(1).first?.string }
                    let fullText = textLines.joined(separator: "\n")
                    DispatchQueue.main.async {
                        // set rawText then reuse the same parser
                        self.rawText = fullText
                        self.parseFromRawText()
                        self.uploadCompleted = true
                        print("[AddPatientViewModel] OCR -> rawText: \(fullText)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.uploadCompleted = false
                    }
                }
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.uploadCompleted = false
                }
                print("Vision error: \(error)")
            }
        }
    }
    
    // MARK: - Appointments
    func addAppointment(packet: AppointmentPacket) {
        let date = appointmentDates[packet.id] ?? Date()
        let needs = needsConsultation[packet.id] ?? false
        let appt = Appointment(name: packet.name, date: date, time: date, consultation: needs)
        if !selectedAppointments.contains(where: { $0.name == appt.name && Calendar.current.isDate($0.date, inSameDayAs: appt.date) }) {
            selectedAppointments.append(appt)
        }
    }
    
    // MARK: - Save
    func savePatient() {
        // persist to DB / SwiftData / etc.
        print("Saving patient: \(name) / \(nik) / \(dobString) / \(phoneNumber) / \(address)")
    }
    
    // Reset everything
    func clearInput() {
        rawText = ""
        nik = ""
        name = ""
        dobString = ""
        phoneNumber = ""
        address = ""
        uploading = false
        uploadCompleted = false
    }
}

// models
struct Appointment: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let time: Date
    let consultation: Bool
}

struct AppointmentPacket: Identifiable {
    let id = UUID()
    let name: String
    let department: String
}
