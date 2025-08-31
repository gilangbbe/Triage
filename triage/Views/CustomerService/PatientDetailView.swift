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
                                    
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.white)
                                        .background(.blue)
                                        .clipShape(Capsule())
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
                                ScrollView {
                                    ForEach(0..<10, id: \.self) { i in
                                        AppointmentListRow()
                                    }
                                }
//                                if patient.appointments.isEmpty {
//                                    Text("No Appointment History")
//                                        .font(.headline)
//                                        .foregroundColor(.secondary)
//                                } else {
//                                    ScrollView {
//                                        ForEach(0..<10, id: \.self) { i in
//                                            AppointmentListRow()
//                                        }
//                                    }
//                                }
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
                Group {
                    VStack(alignment: .leading) {
                        FormField(
                            icon: "person.text.rectangle.fill",
                            label: "NATIONAL IDENTITY NUMBER",
                            placeholder: "Enter 16 Digits",
                            value: patient.nationalID ?? "Not provided",
                            enableEditButtonDisplay: true
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
    var enableEditButtonDisplay: Bool = false
    @Binding var text: String
    
    init(icon: String, label: String, placeholder: String, text: Binding<String>) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = nil
        self._text = text
    }
    
    init(icon: String, label: String, placeholder: String, value: String, enableEditButtonDisplay: Bool = false) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self._text = .constant("")
        self.enableEditButtonDisplay = enableEditButtonDisplay
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(label)
                .foregroundColor(.gray)
            if enableEditButtonDisplay {
                Spacer()
                Button(action: {
                    // handle edit action here
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Capsule())
                }
            }
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

