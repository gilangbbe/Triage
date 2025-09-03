//
//  AddPatientViewModel.swift
//  triage
//
//  Created by Chiquitta Kellie on 28/08/25.
//

import SwiftUI
import Vision
import UIKit

@Observable
class AddPatientViewModel {
    // MARK: - Types
    enum InputMode {
        case paste
        case idCard
    }
    
    enum ValidationStep: Int, CaseIterable {
        case dataInput = 1
        case confirmation = 2
        case appointments = 3
        
        var title: String {
            switch self {
            case .dataInput: return "Patient Details"
            case .confirmation: return "Confirm Patient"
            case .appointments: return "Appointments"
            }
        }
    }
    
    // MARK: - Patient Data Properties
    var rawText: String = ""
    var nationalId: String? = nil
    var fullName: String = ""
    var dateOfBirth: Date? = nil
    var phoneNumber: String = ""
    var address: String = ""
    var gender: Gender? = nil
    
    // MARK: - UI State Properties
    var inputMode: InputMode = .paste
    var isUploading: Bool = false
    var uploadCompleted: Bool = false
    var didParseStep1: Bool = false
    var idCardImage: UIImage? = nil
    
    // MARK: - Appointment Properties (New System)
    var selectedAppointments: [AppointmentSelection] = []
    var availablePackages: [Package] = []
    var availableTimeSlots: [TimeSlotOption] = []
    
    // MARK: - Dependencies
    private let patientManager: PatientManager
    private let appointmentManager: AppointmentManager
    private let packageManager: PackageManager
    private let ocrService: OCRService
    
    // MARK: - Initialization
    init(patientManager: PatientManager, appointmentManager: AppointmentManager, packageManager: PackageManager) {
        self.patientManager = patientManager
        self.appointmentManager = appointmentManager
        self.packageManager = packageManager
        self.ocrService = OCRService()
        loadAvailablePackages()
    }
    
    // MARK: - Validation
    func isStepValid(_ step: ValidationStep) -> Bool {
        switch step {
        case .dataInput:
            return hasValidInput
        case .confirmation:
            return hasValidPatientData
        case .appointments:
            return hasValidAppointments
        }
    }
    
    // Legacy method for int-based validation
    func isStepValid(_ step: Int) -> Bool {
        guard let validationStep = ValidationStep(rawValue: step) else { return false }
        return isStepValid(validationStep)
    }
    
    var isValidAll: Bool {
        ValidationStep.allCases.allSatisfy { isStepValid($0) }
    }
    
    var isFormComplete: Bool {
        isValidAll
    }
    
    private var hasValidInput: Bool {
        !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploadCompleted
    }
    
    private var hasValidPatientData: Bool {
        !fullName.isEmpty
    }
    
    private var hasValidAppointments: Bool {
        !selectedAppointments.isEmpty
    }
    // MARK: - Data Parsing
    func parseFromRawText() {
        let parser = PatientDataParser()
        let parsedData = parser.parse(from: rawText)
        
        applyParsedData(parsedData)
        didParseStep1 = !fullName.isEmpty
    }
    
    func parseIDCardFromImage(fileURL: URL) {
        isUploading = true
        uploadCompleted = false
        didParseStep1 = false
        
        Task {
            do {
                let extractedText = try await ocrService.extractText(from: fileURL)
                await MainActor.run {
                    self.rawText = extractedText
                    self.parseFromRawText()
                    self.isUploading = false
                    self.uploadCompleted = true
                }
            } catch {
                await MainActor.run {
                    self.isUploading = false
                    self.uploadCompleted = false
                }
                print("OCR Error: \(error)")
            }
        }
    }
    
    private func applyParsedData(_ data: ParsedPatientData) {
        nationalId = data.nationalId
        fullName = data.fullName
        dateOfBirth = data.dateOfBirth
        phoneNumber = data.phoneNumber
        address = data.address
        gender = data.gender
    }
    
    // MARK: - Patient Management
    func savePatient() {
        let patient = createPatient()
        patientManager.addPatient(patient)
        
        // Create appointments for the patient
        createAppointments(for: patient)
        
        clearForm()
    }
    
    private func createPatient() -> Patient {
        let patient = Patient(fullName: fullName)
        patient.nationalID = nationalId
        patient.dateOfBirth = dateOfBirth
        patient.gender = gender
        patient.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
        patient.address = address.isEmpty ? nil : address
        patient.registeredAt = Date()
        return patient
    }
    
    private func createAppointments(for patient: Patient) {
        for appointmentSelection in selectedAppointments {
            let timeSlot = TimeSlot(
                date: appointmentSelection.date,
                startTime: appointmentSelection.timeSlot.startTime,
                endTime: appointmentSelection.timeSlot.endTime
            )
            
            let appointmentTitle = "\(patient.fullName) - \(appointmentSelection.package.name)"
            
            let appointment = Appointment(
                name: appointmentTitle,
                date: appointmentSelection.date,
                startTime: appointmentSelection.timeSlot.startTime,
                endTime: appointmentSelection.timeSlot.endTime,
                timeSlot: timeSlot,
                patient: patient,
                package: appointmentSelection.package
            )
            
            appointmentManager.addAppointment(appointment)
        }
    }
    
    // MARK: - Appointment Management
    func addAppointmentSelection(package: Package, date: Date, timeSlot: TimeSlotOption) {
        let selection = AppointmentSelection(
            package: package,
            date: date,
            timeSlot: timeSlot
        )
        selectedAppointments.append(selection)
    }
    
    func removeAppointmentSelection(at index: Int) {
        guard index < selectedAppointments.count else { return }
        selectedAppointments.remove(at: index)
    }
    
    func updateAppointmentSelection(at index: Int, package: Package, date: Date, timeSlot: TimeSlotOption) {
        guard index < selectedAppointments.count else { return }
        selectedAppointments[index] = AppointmentSelection(
            package: package,
            date: date,
            timeSlot: timeSlot
        )
    }
    
    func loadAvailablePackages() {
        availablePackages = packageManager.packages
    }
    
    func updateAvailableTimeSlots(for package: Package, on date: Date) {
        let department = package.department
        let maxSlotsPerHour = department.maxSlot ?? 3
        
        // Generate time slots from 8 AM to 5 PM
        let calendar = Calendar.current
        let workingHours = Array(8...16) // 8 AM to 4 PM (5 PM end time)
        
        availableTimeSlots = workingHours.compactMap { hour in
            guard let startTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date),
                  let endTime = calendar.date(bySettingHour: hour + 1, minute: 0, second: 0, of: date) else {
                return nil
            }
            
            // Count existing appointments for this time slot and department
            let existingAppointments = appointmentManager.appointments.filter { appointment in
                calendar.isDate(appointment.timeSlot.date, inSameDayAs: date) &&
                appointment.timeSlot.startTime.timeIntervalSince1970 == startTime.timeIntervalSince1970 &&
                appointment.package.department.id == department.id
            }
            
            let bookedSlots = existingAppointments.count
            let availableSlots = maxSlotsPerHour - bookedSlots
            
            return TimeSlotOption(
                startTime: startTime,
                endTime: endTime,
                availableSlots: max(0, availableSlots),
                maxSlots: maxSlotsPerHour
            )
        }
        
        // Filter out fully booked slots
        availableTimeSlots = availableTimeSlots.filter { $0.availableSlots > 0 }
    }
    
    func clearInput() {
        clearForm()
    }
    
    private func clearForm() {
        rawText = ""
        nationalId = nil
        fullName = ""
        dateOfBirth = nil
        phoneNumber = ""
        address = ""
        gender = nil
        isUploading = false
        uploadCompleted = false
        didParseStep1 = false
        idCardImage = nil
        selectedAppointments.removeAll()
        availableTimeSlots.removeAll()
    }
}

// MARK: - Supporting Models
struct AppointmentSelection: Identifiable {
    let id = UUID()
    let package: Package
    let date: Date
    let timeSlot: TimeSlotOption
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        
        formatter.dateFormat = "HH:mm"
        let timeString = "\(formatter.string(from: timeSlot.startTime)) - \(formatter.string(from: timeSlot.endTime))"
        
        return "\(package.name) on \(dateString) at \(timeString)"
    }
}

// MARK: - Supporting Services
class OCRService {
    func extractText(from fileURL: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = UIImage(contentsOfFile: fileURL.path)?.cgImage else {
                continuation.resume(throwing: OCRError.invalidImage)
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }
                
                let extractedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: extractedText)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum OCRError: Error {
    case invalidImage
    case noTextFound
}

// MARK: - Data Models
struct ParsedPatientData {
    let nationalId: String?
    let fullName: String
    let dateOfBirth: Date?
    let phoneNumber: String
    let address: String
    let gender: Gender?
}

class PatientDataParser {
    func parse(from text: String) -> ParsedPatientData {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else {
            return ParsedPatientData(nationalId: nil, fullName: "", dateOfBirth: nil, phoneNumber: "", address: "", gender: nil)
        }
        
        let nationalId = extractValue(for: "NIK", from: cleanText)
        let fullName = extractValue(for: "Nama lengkap", from: cleanText)
        let dobString = extractValue(for: "Tgl lahir", from: cleanText)
        let phoneNumber = extractValue(for: "No telp", from: cleanText)
        let address = extractValue(for: "Alamat lengkap", from: cleanText)
        let genderString = extractValue(for: "Jenis kelamin", from: cleanText)
        
        return ParsedPatientData(
            nationalId: nationalId.isEmpty ? nil : nationalId,
            fullName: fullName,
            dateOfBirth: DateParser.parse(from: dobString),
            phoneNumber: phoneNumber,
            address: address,
            gender: GenderParser.parse(from: genderString)
        )
    }
    
    private func extractValue(for key: String, from text: String) -> String {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let pattern = "(?i)" + escapedKey + "\\s*[:：]\\s*([^\\n]*)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return "" }
        
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            let matchRange = match.range(at: 1)
            if matchRange.location != NSNotFound {
                return nsText.substring(with: matchRange).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return ""
    }
}

class DateParser {
    static func parse(from string: String) -> Date? {
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanString.isEmpty else { return nil }
        
        let formatters = [
            createFormatter(format: "dd MMMM yyyy"),
            createFormatter(format: "dd/MM/yyyy"),
            createFormatter(format: "dd-MM-yyyy"),
            createFormatter(format: "dd.MM.yyyy")
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: cleanString) {
                return date
            }
        }
        
        return nil
    }
    
    private static func createFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
}

class GenderParser {
    static func parse(from string: String) -> Gender? {
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanString.hasPrefix("L") || cleanString.contains("LAKI") || cleanString.contains("MALE") {
            return .male
        } else if cleanString.hasPrefix("P") || cleanString.contains("PEREMPUAN") || cleanString.contains("FEMALE") {
            return .female
        }
        
        return nil
    }
}

// MARK: - Date Extensions (Legacy support)
extension Date {
    static func parse(from string: String) -> Date? {
        DateParser.parse(from: string)
    }
    
    static func parse(from string: String, locale: Locale) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = locale
        
        let formats = ["dd MMMM yyyy", "dd/MM/yyyy", "dd-MM-yyyy", "dd.MM.yyyy"]
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    func formattedLong() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: self)
    }
}
