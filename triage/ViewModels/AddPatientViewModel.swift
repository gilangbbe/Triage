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
    
    // MARK: - Step 1 fields
    @Published var rawText: String = ""          // pasted text or OCR result
    @Published var nik: String? = nil
    @Published var name: String = ""
    @Published var dob: Date? = nil
    @Published var phoneNumber: String = ""
    @Published var address: String = ""
    @Published var gender: String? = nil
    @Published var uploading: Bool = false       // OCR parsing running
    @Published var uploadCompleted: Bool = false // OCR finished
    @Published var inputMode: InputMode = .paste
    @Published var didParseStep1: Bool = false
    @Published var idCardImage: UIImage? = nil

    // MARK: - Step 2 (appointments)
    @Published var selectedCategory = "all"
    @Published var selectedAppointments: [Appointment] = []
    @Published var appointmentDates: [UUID: Date] = [:]
    @Published var needsConsultation: [UUID: Bool] = [:]
    
    private var patientManager: PatientManager
    
    var filteredPackets: [Package] { [] } // TODO
    
    init(patientManager: PatientManager) {
        self.patientManager = patientManager
    }
    
    
    // MARK: - Validations
    func isStepValid(_ step: Int) -> Bool {
        switch step {
        case 1:
            return !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploadCompleted
        case 2:
            return !name.isEmpty
        default:
            return true
        }
    }
    
    var isValidAll: Bool {
        isStepValid(1) && isStepValid(2)
    }
    
    var isFormValid: Bool {
        !name.isEmpty
    }
    
    // MARK: - Regex helper
    private func value(for key: String, in text: String) -> String {
        // Allow optional newline before colon
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let pattern = "(?i)" + escapedKey + "\\s*[:：]\\s*([^\\n]*)"          // normal paste
                    + "|(?i)" + escapedKey + "\\s*\\n\\s*[:：]\\s*([^\\n]*)" // OCR

        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsText = text as NSString
            if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)) {
                var val: String? = nil
                if match.numberOfRanges > 1, match.range(at: 1).location != NSNotFound {
                    val = nsText.substring(with: match.range(at: 1))
                } else if match.numberOfRanges > 2, match.range(at: 2).location != NSNotFound {
                    val = nsText.substring(with: match.range(at: 2))
                }
                if let val = val {
                    let trimmed = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    // If it looks like another key (contains colon or known labels), treat as empty
                    let lower = trimmed.lowercased()
                    if trimmed.isEmpty
                        || lower.contains("nama") || lower.contains("nik")
                        || lower.contains("tgl") || lower.contains("alamat")
                        || lower.contains("jenis kelamin") {
                        return ""
                    }
                    return trimmed
                }
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
        
        // --- Step 1: structured format ---
        var nikVal = value(for: "NIK", in: s)
        var nameVal = value(for: "Nama lengkap", in: s)
        var dobVal = value(for: "Tgl lahir", in: s)
        var phoneVal = value(for: "No telp", in: s)
        var addressVal = value(for: "Alamat lengkap", in: s)
        var genderValRaw = value(for: "Jenis kelamin (L/P)", in: s)
        
        // --- Step 2: fallback OCR/KTP parsing ---
        if nameVal.isEmpty {
            nameVal = value(for: "Nama", in: s)
        }
        
        if !dobVal.isEmpty {
            if let commaIdx = dobVal.firstIndex(of: ",") {
                dobVal = String(dobVal[dobVal.index(after: commaIdx)...]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if addressVal.isEmpty {
            let baseAddr = value(for: "Alamat", in: s)
            let rtRw = value(for: "RT/RW", in: s)
            let kel = value(for: "Kel/Desa", in: s)
            let kec = value(for: "Kecamatan", in: s)
            addressVal = [baseAddr, rtRw, kel, kec].filter { !$0.isEmpty }.joined(separator: ", ")
        }
        
        if genderValRaw.isEmpty {
            genderValRaw = value(for: "Jenis Kelamin", in: s)
        }
        
        // --- Step 3: normalize gender ---
        var genderVal: String? = nil
        let g = genderValRaw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if g.hasPrefix("L") { genderVal = "L" }
        else if g.hasPrefix("P") { genderVal = "P" }
        
        // --- Step 4: parse DOB ---
        let parsedDob = Date.parse(from: dobVal)
        
        // --- Step 5: assign to published properties ---
        nik = nikVal.isEmpty ? nil : nikVal
        name = nameVal
        dob = parsedDob
        phoneNumber = phoneVal
        address = addressVal
        gender = genderVal
        
        didParseStep1 = !name.isEmpty
        
        let dobLog = dob != nil ? dob!.formattedLong() : "nil"
//        print("[AddPatientViewModel] parseFromRawText -> nik:\(nik ?? "") name:\(name) dob:\(dobLog) phone:\(phoneNumber) address:\(address) gender:\(gender ?? "")")
        
        print(inputMode)
    }
    
    // MARK: - OCR from image
    func parseIDCardFromImage(fileURL: URL) {
        uploading = true
        uploadCompleted = false
        didParseStep1 = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            defer {
                DispatchQueue.main.async { self.uploading = false }
            }
            
            guard let data = try? Data(contentsOf: fileURL),
                  let uiImage = UIImage(data: data),
                  let cgImage = uiImage.cgImage else {
                DispatchQueue.main.async { self.uploadCompleted = false }
                return
            }
            
            DispatchQueue.main.async { self.idCardImage = uiImage }
            
            let request = VNRecognizeTextRequest { request, error in
                if let observations = request.results as? [VNRecognizedTextObservation] {
                    let textLines = observations.compactMap { $0.topCandidates(1).first?.string }
                    let fullText = textLines.joined(separator: "\n")
                    DispatchQueue.main.async {
                        self.rawText = fullText
                        self.parseFromRawText()
                        self.uploadCompleted = true
//                        print("[AddPatientViewModel] OCR -> rawText: \(fullText)")
                    }
                } else {
                    DispatchQueue.main.async { self.uploadCompleted = false }
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { self.uploadCompleted = false }
                print("Vision error: \(error)")
            }
        }
    }
    
    // MARK: - Appointments
    func addAppointment(packet: Package) {
        let date = appointmentDates[packet.id] ?? Date()
        let needs = needsConsultation[packet.id] ?? false
        let appt = Appointment(name: packet.name, date: date, time: date, consultation: needs)
        if !selectedAppointments.contains(where: { $0.name == appt.name && Calendar.current.isDate($0.date, inSameDayAs: appt.date) }) {
            selectedAppointments.append(appt)
        }
    }
    
    // MARK: - Save / Clear
    func savePatient() {
        let dobText = dob?.formattedLong() ?? "-"
        let patient = Patient(fullName: name)
        patient.nationalID = nik
        patient.dateOfBirth = dob
        patient.gender = gender == "L" ? .male : .female
        patient.phoneNumber = phoneNumber
        patient.address = address
        patient.registeredAt = Date()
        patientManager.addPatient(patient)
        print("Saving patient: \(name) / \(nik ?? "-") / \(dobText) / \(phoneNumber) / \(address) / \(gender ?? "-")")
    }
    
    func clearInput() {
        rawText = ""
        nik = nil
        name = ""
        dob = nil
        phoneNumber = ""
        address = ""
        gender = nil
        uploading = false
        uploadCompleted = false
    }
}

// MARK: - Date Extensions
extension Date {
    static func parse(from string: String) -> Date? {
        parse(from: string, locale: Locale(identifier: "id_ID"))
            ?? parse(from: string, locale: Locale(identifier: "en_US"))
    }
    
    static func parse(from string: String, locale: Locale) -> Date? {
        let formats = ["dd-MM-yyyy", "d-MM-yyyy", "d MMMM yyyy", "dd MMMM yyyy"]
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    func formattedLong() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self)
    }
}
