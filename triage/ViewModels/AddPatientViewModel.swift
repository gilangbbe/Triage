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

    // MARK: - Step 3 (appointments)
    @Published var tempUnit: String = ""
    @Published var tempPackage: String = ""
    @Published var availableServiceAppointments: [ServiceAppointment] = []
    @Published var selectedServiceAppointments: [ServiceAppointment] = []
    @Published var selectedServiceAppointment: ServiceAppointment?
    
    @Published var tempDept: String = ""
    @Published var tempDoctor: String = ""
    @Published var doctorAppointments: [DoctorAppointment] = []
    @Published var selectedDoctorAppointments: [DoctorAppointment] = []
    @Published var selectedDoctorAppointment: DoctorAppointment?
    
    init() {
        generateDummyServiceAppointments()
        generateDummyDoctorAppointments()
    }
    
    func generateDummyServiceAppointments() {
        let units: [String: [String]] = [
            "Medical Check Up": ["Paket MCU Basic", "Paket MCU Standard", "Paket MCU Premium"],
            "Laboratory": ["Paket Lab Darah", "Paket Lab Urine", "Paket Lab Lengkap"],
            "Radiology": ["Paket Rontgen", "Paket MRI", "Paket CT Scan"],
            "Pharmacy": ["Paket Vitamin", "Paket Obat Harian", "Paket Suplemen"]
        ]
        
        let calendar = Calendar.current
        let today = Date()
        
        let workingHours = [
            (8, 9), (9, 10), (10, 11), (11, 12),
            (13, 14), (14, 15), (15, 16), (16, 17)
        ]
        
        for (unit, packages) in units {
            for package in packages {
                for (startHour, endHour) in workingHours {
                    if let start = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: today),
                       let end = calendar.date(bySettingHour: endHour, minute: 0, second: 0, of: today) {
                        
                        let appointment = ServiceAppointment(
                            name: package,
                            unit: unit,
                            startTime: start,
                            endTime: end,
                            maxSlots: 3
                        )
                        availableServiceAppointments.append(appointment)
                    }
                }
            }
        }
    }
    
    func generateDummyDoctorAppointments() {
        let departments: [String: [String]] = [
            "Cardiology": ["Dr. Andi", "Dr. Budi", "Dr. Citra"],
            "Neurology": ["Dr. Dedi", "Dr. Eka", "Dr. Fajar"],
            "Dermatology": ["Dr. Gita", "Dr. Hadi", "Dr. Intan"],
            "Pediatrics": ["Dr. Jaka", "Dr. Kiki", "Dr. Lina"],
            "Orthopedics": ["Dr. Mario", "Dr. Nia", "Dr. Oka"]
        ]

        let calendar = Calendar.current
        let today = Date()
        let workingHours = [9, 10, 11, 13, 14, 15] // starting hours

        for (dept, doctors) in departments {
            for doctor in doctors {
                for dayOffset in 0..<3 { // today + 2 more days
                    guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                    
                    for hour in workingHours {
                        guard let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) else { continue }
                        let appt = DoctorAppointment(
                            department: dept,
                            name: doctor,
                            date: date,
                            startTime: start,
                            maxSlots: 3,
                            bookedSlots: 0
                        )
                        doctorAppointments.append(appt)
                    }
                }
            }
        }
    }
    
    func bookServiceAppointment(_ appointment: ServiceAppointment) {
        guard let index = availableServiceAppointments.firstIndex(where: { $0.id == appointment.id }) else { return }
        
        if availableServiceAppointments[index].availableSlots > 0 {
            availableServiceAppointments[index].bookedSlots += 1
            selectedServiceAppointments.append(availableServiceAppointments[index])
        }
        
        print(selectedServiceAppointments)
    }
    
    func bookDoctorAppointment(_ appointment: DoctorAppointment) {
        guard let index = doctorAppointments.firstIndex(where: { $0.id == appointment.id }) else { return }
        if doctorAppointments[index].bookedSlots < doctorAppointments[index].maxSlots {
            doctorAppointments[index].bookedSlots += 1
            selectedDoctorAppointments.append(doctorAppointments[index])
        }
    }
    
    // MARK: - Update Service Appointment
    func updateServiceAppointment(_ newAppointment: ServiceAppointment) {
        // 1. Find the old appointment
        if let selectedIndex = selectedServiceAppointments.firstIndex(where: { $0.id == newAppointment.id }) {
            let oldAppointment = selectedServiceAppointments[selectedIndex]

            // 2. Decrement old slot booking in availableServiceAppointments
            if let oldAvailableIndex = availableServiceAppointments.firstIndex(where: { $0.startTime == oldAppointment.startTime &&
                                                                                       $0.endTime == oldAppointment.endTime &&
                                                                                       $0.unit == oldAppointment.unit &&
                                                                                       $0.name == oldAppointment.name }) {
                if availableServiceAppointments[oldAvailableIndex].bookedSlots > 0 {
                    availableServiceAppointments[oldAvailableIndex].bookedSlots -= 1
                }
            }

            // 3. Increment new slot booking in availableServiceAppointments
            if let newAvailableIndex = availableServiceAppointments.firstIndex(where: { $0.startTime == newAppointment.startTime &&
                                                                                       $0.endTime == newAppointment.endTime &&
                                                                                       $0.unit == newAppointment.unit &&
                                                                                       $0.name == newAppointment.name }) {
                if availableServiceAppointments[newAvailableIndex].bookedSlots < availableServiceAppointments[newAvailableIndex].maxSlots {
                    availableServiceAppointments[newAvailableIndex].bookedSlots += 1
                    selectedServiceAppointments[selectedIndex] = availableServiceAppointments[newAvailableIndex]
                }
            } else {
                // fallback: if new slot not found in available list, just replace directly
                selectedServiceAppointments[selectedIndex] = newAppointment
            }
        } else {
            // fallback: if not found, treat as booking
            bookServiceAppointment(newAppointment)
        }
    }

    // MARK: - Update Doctor Appointment
    func updateDoctorAppointment(_ newAppointment: DoctorAppointment) {
        // 1. Find the old appointment inside selectedDoctorAppointments
        if let selectedIndex = selectedDoctorAppointments.firstIndex(where: { $0.id == newAppointment.id }) {
            let oldAppointment = selectedDoctorAppointments[selectedIndex]

            // 2. Decrement old slot booking in doctorAppointments
            if let oldAvailableIndex = doctorAppointments.firstIndex(where: {
                $0.department == oldAppointment.department &&
                $0.name == oldAppointment.name &&
                $0.date == oldAppointment.date &&
                $0.startTime == oldAppointment.startTime
            }) {
                if doctorAppointments[oldAvailableIndex].bookedSlots > 0 {
                    doctorAppointments[oldAvailableIndex].bookedSlots -= 1
                }
            }

            // 3. Increment new slot booking in doctorAppointments
            if let newAvailableIndex = doctorAppointments.firstIndex(where: {
                $0.department == newAppointment.department &&
                $0.name == newAppointment.name &&
                $0.date == newAppointment.date &&
                $0.startTime == newAppointment.startTime
            }) {
                if doctorAppointments[newAvailableIndex].bookedSlots < doctorAppointments[newAvailableIndex].maxSlots {
                    doctorAppointments[newAvailableIndex].bookedSlots += 1
                    selectedDoctorAppointments[selectedIndex] = doctorAppointments[newAvailableIndex]
                }
            } else {
                // fallback: if new slot not found, just overwrite
                selectedDoctorAppointments[selectedIndex] = newAppointment
            }
        } else {
            // fallback: if not found, just book new
            bookDoctorAppointment(newAppointment)
        }
    }


    // MARK: - Validations
    func isStepValid(_ step: Int) -> Bool {
        switch step {
        case 1:
            return !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploadCompleted
        case 2:
            return !name.isEmpty
        case 3:
            return !selectedServiceAppointments.isEmpty || !selectedDoctorAppointments.isEmpty
        default:
            return true
        }
    }
    
    var isValidAll: Bool {
        isStepValid(1) && isStepValid(2) && isStepValid(3)
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
    
    // MARK: - Save / Clear
    func savePatient() {
        let dobText = dob?.formattedLong() ?? "-"
        print("Saving patient: \(name) / \(nik ?? "-") / \(dobText) / \(phoneNumber) / \(address) / \(gender ?? "-")")
        print("Service appointments: \(selectedServiceAppointments)")
//                print("Doctor appointments: \(doctorAppointments)")
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
        selectedServiceAppointments.removeAll()
//        doctorAppointments.removeAll()
    }
}

// MARK: - Models


struct ServiceAppointment: Identifiable {
    let id: UUID
    let name: String
    let unit: String
    let startTime: Date
    let endTime: Date
    let maxSlots: Int
    var bookedSlots: Int = 0

    init(id: UUID = UUID(), name: String, unit: String, startTime: Date, endTime: Date, maxSlots: Int, bookedSlots: Int = 0) {
        self.id = id
        self.name = name
        self.unit = unit
        self.startTime = startTime
        self.endTime = endTime
        self.maxSlots = maxSlots
        self.bookedSlots = bookedSlots
    }

    var availableSlots: Int { maxSlots - bookedSlots }
}

struct DoctorAppointment: Identifiable {
    let id: UUID
    let department: String
    let name: String
    let date: Date
    let startTime: Date
    var bookedSlots: Int = 0
    let maxSlots: Int

    init(id: UUID = UUID(), department: String, name: String, date: Date, startTime: Date, maxSlots: Int, bookedSlots: Int = 0) {
        self.id = id
        self.department = department
        self.name = name
        self.date = date
        self.startTime = startTime
        self.maxSlots = maxSlots
        self.bookedSlots = bookedSlots
    }

    var availableSlots: Int { maxSlots - bookedSlots }
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
