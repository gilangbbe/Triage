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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(patient.fullName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                    .foregroundColor(.accentColor)
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
                                            AppointmentListRowView()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 280)
                            .padding()
                            .background(Color.placeholder)
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
                                            AppointmentListRowView()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 280)
                            .padding()
                            .background(Color.placeholder)
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
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.placeholder)
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
                    .foregroundColor(isEditing ? .accentColor : .gray)
                    .background(Color.placeholder)
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
                .accentColor(.accentColor)
                .tint(.accentColor)
            }
            .padding(.leading)
            .padding(.bottom, 16)
            
            // Other fields
            FormFieldView(
                icon: "phone.fill",
                label: "PHONE NUMBER",
                placeholder: "Enter Phone Number",
                text: Binding(
                    get: { patient.phoneNumber ?? "" },
                    set: { patient.phoneNumber = $0.isEmpty ? nil : $0 }
                ),
                isEditing: isEditing
            )
            FormFieldView(
                icon: "house.fill",
                label: "ADDRESS",
                placeholder: "Enter Address",
                text: Binding(
                    get: { patient.address ?? "" },
                    set: { patient.address = $0.isEmpty ? nil : $0 }
                ),
                isEditing: isEditing

            )
            FormFieldView(
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
