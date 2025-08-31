//
//  PatientDetailView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 28/08/25.
//

import SwiftUI

struct PatientDetailView: View {
    let patient: Patient
    @State private var name: String = ""
    @State private var age: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(patient.fullName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                Spacer()
                Button(action: {
                    // handle edit action here
                }) {
                    Text("Edit")
                        .font(.body)
                        .foregroundColor(.gray) // you can style this like a link or button
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            HStack(alignment: .top, spacing: 16) {
                // Patient Appointment
                Group {
                    VStack(alignment: .leading) {
                        Group {
                            HStack {
                                Image(systemName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
                                Text("UPCOMING APPOINTMENT")
                            }
                            
                            VStack {
                                ScrollView {
                                    ForEach(0..<4, id: \.self) { i in
                                        AppointmentListRow()
                                    }
                                }
                            }
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
                                ScrollView {
                                    ForEach(0..<4, id: \.self) { i in
                                        AppointmentListRow()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                // Patient Profile
                Group {
                    VStack(alignment: .leading) {
                        FormField(
                            icon: "person.text.rectangle.fill",
                            label: "NATIONAL IDENTITY NUMBER",
                            placeholder: "Enter 16 Digits",
                            value: patient.nationalID ?? "Not provided"
                        )
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                FormField(
                                    icon: "mappin.and.ellipse",
                                    label: "PLACE",
                                    placeholder: "Enter Place of Birth",
                                    value: patient.placeOfBirth ?? "Not provided"
                                )
                            }
                            VStack(alignment: .leading) {
                                FormField(
                                    icon: "calendar.and.person",
                                    label: "DATE OF BIRTH",
                                    placeholder: "Enter Date-Month-Year",
                                    value: formattedDateOfBirth
                                )
                            }
                        }
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                FormField(
                                    icon: "tshirt.fill",
                                    label: "GENDER",
                                    placeholder: "Enter Gender",
                                    value: patient.gender?.rawValue ?? "Not provided"
                                )
                            }
                            VStack(alignment: .leading) {
                                FormField(
                                    icon: "calendar.badge.checkmark",
                                    label: "REGISTERED DATE",
                                    placeholder: "Enter Date-Month-Year",
                                    value: formattedRegisteredDate
                                )
                            }
                        }
                        FormField(
                            icon: "phone.fill",
                            label: "PHONE NUMBER",
                            placeholder: "Enter Phone Number",
                            value: patient.phoneNumber ?? "Not provided"
                        )
                        FormField(
                            icon: "house.fill",
                            label: "ADDRESS",
                            placeholder: "Enter Address",
                            value: patient.address ?? "Not provided"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var formattedDateOfBirth: String {
        if let dateOfBirth = patient.dateOfBirth {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: dateOfBirth)
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
}

struct AppointmentListRow: View {
    private var serviceName: String = "Medical Checkup"
    private var date: String = "12/09/2025"
    private var time: String = "10:00 AM"
    
    var body: some View {
        VStack {
            HStack {
                Text(serviceName)
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 4)
            HStack {
                Text(date)
                    .font(.title3)
                Spacer()
                Text(time)
                    .font(.title3)
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
    
    init(icon: String, label: String, placeholder: String, text: Binding<String>) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = nil
        self._text = text
    }
    
    init(icon: String, label: String, placeholder: String, value: String) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self._text = .constant("")
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
        }
        if let displayValue = value {
            Text(displayValue)
                .font(.headline)
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
        } else {
            TextField(placeholder, text: $text)
                .font(.headline)
                .padding()
                .foregroundColor(.black)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
        }
    }
}

#Preview {
    let samplePatient = Patient(fullName: "John Doe")
    
    return PatientDetailView(patient: samplePatient)
}

