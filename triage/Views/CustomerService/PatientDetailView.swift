//
//  PatientDetailView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 28/08/25.
//

import SwiftUI

struct PatientDetailView: View {
    @Bindable var patient: Patient
    @State private var isEditing: Bool = false
    let historyViewModel: HistoryViewModel
    let historyManager: HistoryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(patient.fullName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
            }
            HStack(alignment: .top, spacing: 16) {
                // Patient Appointment
                Group {
                    VStack(alignment: .leading) {
                        Group {
                            HStack {
                                Image(systemName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
                                    .foregroundColor(.brown)
                                Text("UPCOMING APPOINTMENT")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brown)
                                Spacer()
                                Button(action: {
                                    //
                                }) {
                                    Text("Add")
                                }
                            }
                            VStack {
                                if patient.appointments.isEmpty {
                                    Text("No Upcoming Appointment")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ScrollView {
                                        ForEach(0..<4, id: \.self) { i in
                                            AppointmentListRow()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 280)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, 16)
                        }
                        Group {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("APPOINTMENT HISTORY")
                            }
                            
                            VStack {
                                if patient.appointments.isEmpty {
                                    Text("No Appointment History")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ScrollView {
                                        ForEach(0..<10, id: \.self) { i in
                                            AppointmentListRow()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 280)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                // Patient Profile
                profileSection
            }
        }
        .padding(.horizontal, 16)
    }
    private var formattedDateOfBirth: String {
        if let date = patient.dateOfBirth {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: date)
        } else {
            return "Not provided"
        }
    }
    
    private var formattedRegisteredDate: String {
        if let registeredAt = patient.registeredAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: registeredAt)
        } else {
            return "Not provided"
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading) {
            // Registered Date
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .foregroundColor(.gray)
                Text("REGISTERED DATE")
                    .foregroundColor(.gray)
                Spacer()
                Text(formattedRegisteredDate)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom, 16)
            
            // NIK field
            VStack {
                HStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .foregroundColor(.gray)
                    Text("NATIONAL IDENTITY NUMBER")
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        if isEditing {
                            recordPatientUpdateHistory()
                        }
                        
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
                .padding(.leading)
                TextField("Enter 16 Digits", text: Binding(
                    get: { patient.nationalID ?? "" },
                    set: { patient.nationalID = $0.isEmpty ? nil : $0 }
                ))
                    .font(.headline)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 16)
                    .disabled(!isEditing)
            }
            
            // Date of Birth
            HStack {
                Image(systemName: "calendar.and.person")
                    .foregroundColor(.gray)
                Text("DATE OF BIRTH")
                    .foregroundColor(.gray)
                Spacer()
                DatePicker(
                    "Select Date of Birth",
                    selection: Binding(
                        get: { patient.dateOfBirth ?? Date() },
                        set: { patient.dateOfBirth = $0 }
                    ),
                    displayedComponents: .date
                )
                .labelsHidden()
            }
            .padding(.leading)
            .padding(.bottom, 16)
            
            // Other fields
            FormField(
                icon: "phone.fill",
                label: "PHONE NUMBER",
                placeholder: "Enter Phone Number",
                text: Binding(
                    get: { patient.phoneNumber ?? "" },
                    set: { patient.phoneNumber = $0.isEmpty ? nil : $0 }
                ),
                isEditing: isEditing
            )
            FormField(
                icon: "house.fill",
                label: "ADDRESS",
                placeholder: "Enter Address",
                text: Binding(
                    get: { patient.address ?? "" },
                    set: { patient.address = $0.isEmpty ? nil : $0 }
                ),
                isEditing: isEditing

            )
            FormField(
                icon: "tshirt.fill",
                label: "GENDER",
                placeholder: "Enter Gender",
                value: patient.gender?.rawValue ?? "Not provided",
                isEditing: isEditing
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func recordPatientUpdateHistory() {
        let log = History(
            type: .patientDataUpdate(customerCareName: "Okta", patientName: patient.fullName)
        )
        print(log)
        historyViewModel.addHistory(log)
    }
}

struct AppointmentListRow: View {
    private var serviceName: String = "Medical Checkup"
    private var date: String = "22 Agustus 2025"
    private var time: String = "10:00 AM"
    private var package: String = "Paket Merdeka Lite"
    
    var body: some View {
        VStack {
            HStack {
                Text(date)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text(serviceName)
                    .font(.title3)
            }
            .padding(.bottom, 4)
            HStack {
                Text(time)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text(package)
                    .font(.subheadline)
                    .padding(8)
                    .background(.red.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding()
        .background(Color.white) // row background
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct FormField: View {
    let icon: String
    let label: String
    let placeholder: String
    let value: String?
    @Binding var text: String
    var isEditing: Bool = false
    
    init(icon: String, label: String, placeholder: String, text: Binding<String>, isEditing: Bool) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = nil
        self._text = text
        self.isEditing = isEditing
    }
    
    init(icon: String, label: String, placeholder: String, value: String, isEditing: Bool) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self._text = .constant("")
        self.isEditing = isEditing
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(label)
                .foregroundColor(.gray)
        }
        .padding(.leading)
        if let displayValue = value {
            Text(displayValue)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
        } else {
            TextField(placeholder, text: $text)
                .font(.headline)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
                .disabled(!isEditing)
        }
    }
}

//#Preview {
//    let samplePatient = Patient(fullName: "John Doe")
//    
//    return PatientDetailView(patient: samplePatient)
//}

