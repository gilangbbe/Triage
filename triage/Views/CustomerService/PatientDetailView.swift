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
    @State private var showingAddAppointment = false
    
    let historyViewModel: HistoryViewModel
    let historyManager: HistoryManager
    
    @Environment(PackageManager.self) private var packageManager
    @Environment(AppointmentManager.self) private var appointmentManager
    @Environment(PatientManager.self) private var patientManager
    
    // Computed properties to separate upcoming and completed appointments
    private var upcomingAppointments: [Appointment] {
        patient.appointments?.filter { appointment in
            guard let timeSlot = appointment.timeSlot else { return false }
            return timeSlot.date >= Calendar.current.startOfDay(for: Date())
        }.sorted { 
            guard let timeSlot1 = $0.timeSlot, let timeSlot2 = $1.timeSlot else { return false }
            return timeSlot1.date < timeSlot2.date 
        } ?? []
    }
    
    private var completedAppointments: [Appointment] {
        patient.appointments?.filter { appointment in
            guard let timeSlot = appointment.timeSlot else { return false }
            return timeSlot.date < Calendar.current.startOfDay(for: Date())
        }.sorted { 
            guard let timeSlot1 = $0.timeSlot, let timeSlot2 = $1.timeSlot else { return false }
            return timeSlot1.date > timeSlot2.date 
        } ?? []
    }
    
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
                                    showingAddAppointment = true
                                }) {
                                    Text("Add")
                                }
                            }
                            VStack {
                                if upcomingAppointments.isEmpty {
                                    Text("No Upcoming Appointment")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ScrollView {
                                        LazyVStack(spacing: 8) {
                                            ForEach(upcomingAppointments, id: \.id) { appointment in
                                                AppointmentListRow(appointment: appointment)
                                            }
                                        }
                                        .padding(.horizontal, 4)
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
                                if completedAppointments.isEmpty {
                                    Text("No Appointment History")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ScrollView {
                                        ForEach(completedAppointments, id: \.id) { appointment in
                                            AppointmentListRow(appointment: appointment)
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
        .sheet(isPresented: $showingAddAppointment) {
            Step3AppointmentsView(
                viewModel: createAppointmentViewModel(),
                isStandaloneMode: true,
                patient: patient,
                onAppointmentSaved: { package, date, timeSlot in
                    saveAppointment(package: package, date: date, timeSlot: timeSlot)
                },
                onDismiss: {
                    showingAddAppointment = false
                }
            )
            .frame(width: 800)
        }
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
                .disabled(!isEditing)
                .labelsHidden()
            }
            .padding(.leading)
            .padding(.bottom, 16)
            
            // Gender
            HStack {
                Image(systemName: "tshirt.fill")
                    .foregroundColor(.gray)
                Text("GENDER")
                    .foregroundColor(.gray)

                Spacer()

                Picker("Select Gender", selection: Binding(
                    get: { patient.gender ?? .male }, // fallback if nil
                    set: { patient.gender = $0 }
                )) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender as Gender?)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isEditing ? Color.placeholder : Color.clear) // ✅ only picker highlighted
                )
                .disabled(!isEditing)
                .labelsHidden()
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
        }
        .frame(maxWidth: .infinity)
    }
    
    private func recordPatientUpdateHistory() {
        if let user = UserManager.shared.loadUserProfile() {
            let log = History(
                type: .patientDataUpdate(customerCareName: user.fullName, patientName: patient.fullName)
            )
            historyViewModel.addHistory(log)
        }
    }
    
    // MARK: - Appointment Management
    private func createAppointmentViewModel() -> AddPatientViewModel {
        // Create a minimal view model just for appointment management
        let viewModel = AddPatientViewModel(
            patientManager: patientManager,
            appointmentManager: appointmentManager,
            packageManager: packageManager
        )
        return viewModel
    }
    
    private func saveAppointment(package: Package, date: Date, timeSlot: TimeSlotOption) {
        let timeSlotModel = TimeSlot(
            date: date,
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime
        )
        
        let appointmentTitle = "\(patient.fullName) - \(package.name)"
        
        let appointment = Appointment(
            name: appointmentTitle,
            date: date,
            startTime: timeSlot.startTime,
            endTime: timeSlot.endTime,
            timeSlot: timeSlotModel,
            patient: patient,
            package: package
        )
        
        appointmentManager.addAppointment(appointment)
    }
}

struct AppointmentListRow: View {
    var appointment: Appointment
    
    var body: some View {
        VStack {
            HStack {
                if let timeSlot = appointment.timeSlot {
                    Text(timeSlot.date.formatted(date: .long, time: .omitted))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                } else {
                    Text("No date scheduled")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(appointment.package?.department?.name ?? "Unknown Department")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 4)
            HStack {
                if let timeSlot = appointment.timeSlot {
                    Text(timeSlot.startTime.formatted(date: .omitted, time: .shortened))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                } else {
                    Text("No time scheduled")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(appointment.package?.name ?? "Unkown Package")
                    .font(.subheadline)
                    .padding(8)
                    .background(.red.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
