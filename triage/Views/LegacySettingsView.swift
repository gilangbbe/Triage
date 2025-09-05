//
//  SettingsView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 22/08/25.
//

import SwiftUI
import SwiftData

struct LegacySettingsView: View {
    @Environment(PatientManager.self) private var patientManager
    @Environment(QuickReplyManager.self) private var quickReplyManager
    @State private var showingClearAllAlert = false
    @State private var showingKeyboardInstructions = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Keyboard Extension") {
                    Button("Setup Instructions") {
                        showingKeyboardInstructions = true
                    }
                    .foregroundColor(.blue)
                    
                    NavigationLink("Quick Replies") {
                        QuickRepliesView()
                    }
                    
                    NavigationLink("Test Parsing") {
                        TestParsingView()
                    }
                }
                
                Section("Data Management") {
                    Button("Export Data") {
                        exportData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Patients") {
                        showingClearAllAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConfiguration.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App Group ID")
                        Spacer()
                        Text(AppConfiguration.appGroupID)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Clear All Patients", isPresented: $showingClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllPatients()
            }
        } message: {
            Text("This action cannot be undone. All patient records will be permanently deleted.")
        }
        .sheet(isPresented: $showingKeyboardInstructions) {
            KeyboardInstructionsView()
        }
    }
    
    private func exportData() {
        let patients = patientManager.patients
        let patientData = patients.map { patient in
            PatientData(
                id: patient.id.uuidString,
                fullName: patient.fullName,
                nationalID: patient.nationalID,
                dateOfBirth: patient.dateOfBirth,
                gender: patient.gender?.rawValue,
                placeOfBirth: patient.placeOfBirth,
                phoneNumber: patient.phoneNumber,
                address: patient.address
            )
        }
        
        guard let data = try? JSONEncoder().encode(patientData),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }
        
        // Simple sharing - for now just print to console
        print("Patient data exported:")
        print(jsonString)
    }
    
    private func clearAllPatients() {
        patientManager.clearAllPatients()
    }
}

struct KeyboardInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Setting Up the Keyboard Extension")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionStep(number: 1, title: "Enable the Keyboard", description: "Go to Settings > General > Keyboard > Keyboards > Add New Keyboard and select 'Triage Parser'")
                        
                        InstructionStep(number: 2, title: "Allow Full Access", description: "In the keyboard settings, enable 'Allow Full Access' for the Triage Parser keyboard")
                        
                        InstructionStep(number: 3, title: "Using the Extension", description: "When typing in any app, switch to the Triage Parser keyboard and paste customer messages to parse them automatically")
                    }
                    
                    Text("Supported Format:")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("name: John Doe")
                        Text("email: john@example.com")
                        Text("address: 123 Main Street")
                        Text("phone: +1234567890")
                        Text("order: 2x Coffee, 1x Sandwich")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Text("The parser is flexible and will work with variations like 'nama', 'alamat', 'hp', etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding()
            }
            .navigationTitle("Keyboard Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TestParsingView: View {
    @State private var testText = """
    name: John Doe
    nik: 1234567890123456
    dob: 15/08/1990
    gender: Man
    place of birth: Jakarta
    phone: +62-812-3456-7890
    address: Jl. Sudirman No. 123, Jakarta Pusat
    """
    @State private var parsedPatient: Patient?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Test the patient parsing functionality by entering sample text:")
                .font(.headline)
            
            TextEditor(text: $testText)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button("Parse Text") {
                parsedPatient = Patient.parseFromText(testText)
            }
            .buttonStyle(.borderedProminent)
            
            if let patient = parsedPatient {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parsed Result:")
                        .font(.headline)
                    
                    Text("Name: \(patient.fullName)")
                    if let nik = patient.nationalID {
                        Text("NIK: \(nik)")
                    }
                    if let dob = patient.dateOfBirth {
                        Text("Date of Birth: \(dob, style: .date)")
                    }
                    if let gender = patient.gender {
                        Text("Gender: \(gender.rawValue)")
                    }
                    if let birthPlace = patient.placeOfBirth {
                        Text("Place of Birth: \(birthPlace)")
                    }
                    if let phone = patient.phoneNumber {
                        Text("Phone: \(phone)")
                    }
                    if let address = patient.address {
                        Text("Address: \(address)")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Test Patient Parsing")
    }
}

#Preview {
    SettingsView()
        .environment(PatientManager.shared)
        .environment(QuickReplyManager.shared)
}
