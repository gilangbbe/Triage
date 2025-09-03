// //
// //  Step3AppointmentsView.swift
// //  triage
// //
// //  Created by Chiquitta Kellie on 30/08/25.
// //

// import SwiftUI

// struct Step3AppointmentsView: View {
//    @Bindable var viewModel: AddPatientViewModel
   
//    @State private var showServiceForm = false
//    @State private var showDoctorForm = false
//    @State private var editingServiceAppointment: ServiceAppointment?
//    @State private var editingDoctorAppointment: DoctorAppointment?
   
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
           
//            // Title
//            Text("Patient Appointment")
//                .font(.headline)
//                .padding(.horizontal)
//                .foregroundColor(Color(hex: "#0F0E46"))
           
//            // Two Columns
//            HStack(alignment: .top, spacing: 16) {
               
//                // MARK: - Service Unit
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Medical Service Unit")
//                        .font(.subheadline)
//                        .bold()
//                        .foregroundColor(Color(hex: "#0F0E46"))
                   
//                    AddRowButton {
//                        showServiceForm = true
//                    }
                   
//                    ScrollView {
//                        ForEach(viewModel.selectedServiceAppointments) { appt in
//                            AppointmentCard_Service(appt: appt)
//                                .padding(.bottom, 6)
//                                .onTapGesture {
//                                    editingServiceAppointment = appt
//                                    showServiceForm = true
//                                }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
               
//                Divider()
//                    .frame(height: .infinity)
               
//                // MARK: - Doctor Appointment
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Doctor’s Appointment")
//                        .font(.subheadline)
//                        .bold()
//                        .foregroundColor(Color(hex: "#0F0E46"))
                   
//                    AddRowButton {
//                        showDoctorForm = true
//                    }
                   
//                    ScrollView {
//                        ForEach(viewModel.selectedDoctorAppointments) { appt in
//                            AppointmentCard_Doctor(appt: appt)
//                                .padding(.bottom, 6)
//                                .onTapGesture {
//                                    editingDoctorAppointment = appt
//                                    showDoctorForm = true
//                                }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.horizontal)
           
//            Spacer()
//        }
//        .padding()
//        .sheet(isPresented: $showServiceForm) {
//            NavigationStack {
//                ServiceAppointmentForm(
//                    viewModel: viewModel,
//                    existingAppointment: editingServiceAppointment
//                ) {
//                    editingServiceAppointment = nil
//                }
//            }
//            .presentationDetents([.medium])
//        }

//        .sheet(isPresented: $showDoctorForm) {
//            NavigationStack {
//                DoctorAppointmentForm(
//                    viewModel: viewModel,
//                    existingAppointment: editingDoctorAppointment
//                ) {
//                    editingDoctorAppointment = nil
//                }
//            }
//            .presentationDetents([.medium])
//        }

//    }
// }


// // MARK: - Add Row Button
// struct AddRowButton: View {
//    var title: String = "+ Add"
//    var action: () -> Void

//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Spacer()
//                Text(title)
//                    .font(.footnote)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                    .padding(.vertical, 5)
//                Spacer()
//            }
//            .background(Color(UIColor.systemGray5))
//            .cornerRadius(6)
//            .padding(.vertical, 6)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .contentShape(Rectangle())
//    }
// }

// // MARK: - Service Appointment Form
// struct ServiceAppointmentForm: View {
//    @ObservedObject var viewModel: AddPatientViewModel
//    @Environment(\.dismiss) private var dismiss
   
//    var existingAppointment: ServiceAppointment? = nil
//    var onDismiss: () -> Void = {}
   
//    @State private var selectedUnit = ""
//    @State private var selectedPackage = ""
//    @State private var selectedDate = Date()
//    @State private var showTimePicker = false
//    @State private var showPackageModal = false
   
//    var body: some View {
//        VStack(spacing: 16) {
           
//            // Step 1: Paket
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Medical Service Unit")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
               
//                Button(action: { showPackageModal = true }) {
//                    HStack {
//                        if selectedUnit.isEmpty && selectedPackage.isEmpty {
//                            HStack {
//                                Image(systemName: "magnifyingglass")
//                                    .foregroundColor(.gray)
//                                Text("Select Medical Service Unit")
//                                    .foregroundColor(.gray)
//                                    .font(.subheadline)
//                            }
//                        } else {
//                            HStack {
//                                Text(selectedUnit)
//                                    .font(.subheadline)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(Color(hex: "#0F0E46"))
//                                Text(" - ")
//                                    .font(.subheadline)
//                                    .foregroundColor(Color(hex: "#0F0E46"))
//                                Text(selectedPackage)
//                                    .font(.subheadline)
//                                    .foregroundColor(Color(hex: "#0F0E46"))
//                            }
//                        }
//                    }
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(6)
//                }
//                .buttonStyle(.plain)
//                .sheet(isPresented: $showPackageModal) {
//                    ServiceUnitSearchModal(
//                        viewModel: viewModel,
//                        selectedUnit: $selectedUnit,
//                        selectedPackage: $selectedPackage
//                    )
//                }
//            }
           
//            // Step 2: Date
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Date".uppercased())
//                    .font(.caption2)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                DatePicker(
//                    dateString(selectedDate), // empty label
//                    selection: $selectedDate,
//                    displayedComponents: .date
//                )
//                .labelsHidden()
//                .datePickerStyle(.compact)
//                .font(.subheadline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color(.clear))
//                .cornerRadius(6)
//            }
           
//            // Step 3: Time
//            VStack(alignment: .leading, spacing: 6) {
//                Text("TIME & AVAILABLE SLOT".uppercased())
//                    .font(.caption2)
//                    .foregroundColor(Color(hex: "#0F0E46"))
               
//                Button {
//                    showTimePicker = true
//                } label: {
//                    HStack {
//                        if let selected = viewModel.selectedServiceAppointment {
//                            Text("\(timeString(selected.startTime)) - \(timeString(selected.endTime))")
//                                .font(.subheadline)
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text(selected.displayText)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        } else {
//                            Text("Pick a Time")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        }
//                    }
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(6)
//                }
//                .sheet(isPresented: $showTimePicker) {
//                    TimePickerModal(
//                        appointments: filteredAppointments,
//                        selectedAppointment: $viewModel.selectedServiceAppointment,
//                        isPresented: $showTimePicker,
//                        onConfirm: { }
//                    )
//                }
//                .disabled(selectedPackage.isEmpty)
//                .opacity(selectedPackage.isEmpty ? 0.6 : 1)
//            }
           
//            Spacer()
//        }
//        .padding()
//        .navigationTitle(existingAppointment == nil ? "New Service Appointment" : "Edit Service Appointment")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            if let appt = existingAppointment {
//                selectedUnit = appt.unit
//                selectedPackage = appt.name
//                selectedDate = appt.startTime
//                viewModel.selectedServiceAppointment = appt
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") {
//                    dismiss()
//                    onDismiss()
//                }
//            }
//            ToolbarItem(placement: .confirmationAction) {
//                Button(existingAppointment == nil ? "Add" : "Edit") {
//                    if let existing = existingAppointment {
//                        // build updated appointment from existing + new values
//                        let updated = ServiceAppointment(
//                            id: existing.id,  // preserve ID
//                            name: selectedPackage.isEmpty ? existing.name : selectedPackage,
//                            unit: selectedUnit.isEmpty ? existing.unit : selectedUnit,
//                            startTime: viewModel.selectedServiceAppointment?.startTime ?? existing.startTime,
//                            endTime: viewModel.selectedServiceAppointment?.endTime ?? existing.endTime,
//                            maxSlots: existing.maxSlots,
//                            bookedSlots: existing.bookedSlots
//                        )
//                        viewModel.updateServiceAppointment(updated)
//                    } else if let selected = viewModel.selectedServiceAppointment {
//                        // Add new booking
//                        viewModel.bookServiceAppointment(selected)
//                    }
//                    dismiss()
//                    onDismiss()
//                }
//                .disabled(existingAppointment == nil && viewModel.selectedServiceAppointment == nil)
//            }

//        }
//    }
   
//    // Helpers
//    private func dateString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        return formatter.string(from: date)
//    }
   
//    private var filteredAppointments: [ServiceAppointment] {
//        viewModel.availableServiceAppointments.filter { appt in
//            appt.name == selectedPackage &&
//            (selectedUnit.isEmpty || appt.unit == selectedUnit)
//        }
//    }
   
//    private func timeString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
// }

// struct DoctorAppointmentForm: View {
//    @ObservedObject var viewModel: AddPatientViewModel
//    @Environment(\.dismiss) private var dismiss

//    var existingAppointment: DoctorAppointment? = nil
//    var onDismiss: () -> Void = {}
   
//    @State private var selectedDept: String = ""
//    @State private var selectedDoctor: String = ""
//    @State private var selectedDate: Date = Date()
//    @State private var showTimePicker = false
//    @State private var showDoctorModal = false

//    var body: some View {
//        VStack(spacing: 16) {

//            // MARK: - Doctor Selection
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Doctor".uppercased())
//                    .font(.caption2)
//                    .foregroundColor(Color(hex: "#0F0E46"))

//                Button {
//                    showDoctorModal = true
//                } label: {
//                    HStack {
//                        if selectedDoctor.isEmpty {
//                            Text("Select Doctor")
//                                .foregroundColor(.gray)
//                                .font(.subheadline)
//                        } else {
//                            Text("\(selectedDept) - \(selectedDoctor)")
//                                .foregroundColor(.black)
//                                .font(.subheadline)
//                        }
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(6)
//                }
//                .sheet(isPresented: $showDoctorModal) {
//                    DoctorSearchModal(
//                        viewModel: viewModel,
//                        selectedDept: $selectedDept,
//                        selectedDoctor: $selectedDoctor
//                    )
//                }
//            }

//            VStack(alignment: .leading, spacing: 6) {
//                Text("Date".uppercased())
//                    .font(.caption2)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                DatePicker(
//                    dateString(selectedDate),
//                    selection: $selectedDate,
//                    displayedComponents: .date
//                )
//                .labelsHidden()
//                .datePickerStyle(.compact)
//                .font(.subheadline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color(.clear))
//                .cornerRadius(6)
//            }
           
//            // MARK: - Time Slots
//            VStack(alignment: .leading, spacing: 6) {
//                Text("TIME & AVAILABLE SLOT".uppercased())
//                    .font(.caption2)
//                    .foregroundColor(Color(hex: "#0F0E46"))

//                Button {
//                    showTimePicker = true
//                } label: {
//                    HStack {
//                        if let selected = viewModel.selectedDoctorAppointment {
//                            Text("\(timeString(selected.startTime)) - \(timeString(selected.endTime))")
//                                .font(.subheadline)
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text(selected.displayText)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        } else {
//                            Text("Pick a Time")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        }
//                    }
//                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(6)
//                }
//                .sheet(isPresented: $showTimePicker) {
//                    TimePickerModal(
//                        appointments: filteredAppointments,
//                        selectedAppointment: $viewModel.selectedDoctorAppointment,
//                        isPresented: $showTimePicker,
//                        onConfirm: { }
//                    )
//                }
//                .disabled(selectedDoctor.isEmpty)
//                .opacity(selectedDoctor.isEmpty ? 0.6 : 1)
//            }

//            Spacer()
//        }
//        .padding()
//        .navigationTitle(existingAppointment == nil ? "New Service Appointment" : "Edit Service Appointment")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            if let appt = existingAppointment {
//                selectedDept = appt.department
//                selectedDoctor = appt.name
//                selectedDate = appt.date
//                viewModel.selectedDoctorAppointment = appt
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Cancel") {
//                    dismiss()
//                    onDismiss()
//                }
//            }
//            ToolbarItem(placement: .confirmationAction) {
//                Button(existingAppointment == nil ? "Add" : "Edit") {
//                    if let existing = existingAppointment {
//                        // build updated appointment from existing + new values
//                        let updated = DoctorAppointment(
//                            id: existing.id,  // preserve ID
//                            department: selectedDept.isEmpty ? existing.department : selectedDept,
//                            name: selectedDoctor.isEmpty ? existing.name : selectedDoctor,
//                            date: selectedDate,
//                            startTime: viewModel.selectedDoctorAppointment?.startTime ?? existing.startTime,
//                            maxSlots: existing.maxSlots,
//                            bookedSlots: existing.bookedSlots
//                        )
//                        viewModel.updateDoctorAppointment(updated)
//                    } else if let selected = viewModel.selectedDoctorAppointment {
//                        // Add new booking
//                        viewModel.bookDoctorAppointment(selected)
//                    }
//                    dismiss()
//                    onDismiss()
//                }
//                .disabled(existingAppointment == nil && viewModel.selectedDoctorAppointment == nil)
//            }

//        }
//    }

//    private func dateString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        return formatter.string(from: date)
//    }
   
//    // MARK: - Filtered Appointments for TimePicker
//    private var filteredAppointments: [DoctorAppointment] {
//        viewModel.doctorAppointments.filter {
//            $0.department == selectedDept &&
//            $0.name == selectedDoctor &&
//            Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate)
//        }
//    }

//    private func timeString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
// }




// // MARK: - Date Extensions
// extension Date {
//    func formattedTime() -> String {
//        let f = DateFormatter()
//        f.dateFormat = "HH.mm"
//        return f.string(from: self)
//    }
// }

// struct ServiceUnitSearchModal: View {
//    @Environment(\.dismiss) var dismiss
//    @ObservedObject var viewModel: AddPatientViewModel
//    @Binding var selectedUnit: String
//    @Binding var selectedPackage: String
   
//    @State private var searchText = ""
//    @State private var selectedFilter: String = "All"
   
//    // Temporary selection for this modal
//    @State private var tempUnit: String = ""
//    @State private var tempPackage: String = ""
   
//    var filteredPackages: [ServiceAppointment] {
//        let filtered = viewModel.availableServiceAppointments.filter { appt in
//            (selectedFilter == "All" || appt.unit == selectedFilter) &&
//            (searchText.isEmpty || appt.name.localizedCaseInsensitiveContains(searchText))
//        }
       
//        // Deduplicate by package name
//        var seenNames = Set<String>()
//        let distinct = filtered.filter { appt in
//            if seenNames.contains(appt.name) { return false }
//            seenNames.insert(appt.name)
//            return true
//        }
       
//        // Sort by unit first, then by package name
//        return distinct.sorted { (a, b) in
//            if a.unit == b.unit {
//                return a.name < b.name
//            } else {
//                return a.unit < b.unit
//            }
//        }
//    }
   
//    var uniqueUnits: [String] {
//        Array(Set(viewModel.availableServiceAppointments.map { $0.unit })).sorted()
//    }
   
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Search + filter
//                HStack {
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                        TextField("Search package...", text: $searchText)
//                    }
//                    .padding(8)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
                   
//                    Menu {
//                        Button("All") { selectedFilter = "All" }
//                        ForEach(uniqueUnits, id: \.self) { unit in
//                            Button(unit) { selectedFilter = unit }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedFilter)
//                            Image(systemName: "chevron.down")
//                        }
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 6)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    }
//                }
//                .padding()
               
//                // Package list
//                List(filteredPackages) { appt in
//                    let isSelected = (tempUnit == appt.unit && tempPackage == appt.name)
//                    HStack {
//                        Text(appt.unit)
//                            .font(.subheadline)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Text(" - ")
//                            .font(.subheadline)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Text(appt.name)
//                            .font(.subheadline)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Spacer()
//                        if isSelected {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(Color(hex: "#0F0E46"))
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        if isSelected {
//                            tempUnit = ""
//                            tempPackage = ""
//                        } else {
//                            tempUnit = appt.unit
//                            tempPackage = appt.name
//                        }
//                    }
//                }
//                .listStyle(.plain)
//            }
//            .navigationTitle("Select Medical Service Unit")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss() // discard temp changes
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Select") {
//                        // commit temporary selection
//                        selectedUnit = tempUnit
//                        selectedPackage = tempPackage
//                        dismiss()
//                    }
//                    .disabled(tempPackage.isEmpty)
//                }
//            }
//            .onAppear {
//                // Initialize temp selection with current selection
//                tempUnit = selectedUnit
//                tempPackage = selectedPackage
//            }
//        }
//    }
// }

// struct DoctorSearchModal: View {
//    @Environment(\.dismiss) var dismiss
//    @ObservedObject var viewModel: AddPatientViewModel
//    @Binding var selectedDept: String
//    @Binding var selectedDoctor: String

//    @State private var searchText = ""
//    @State private var selectedFilter: String = "All"
   
//    // Temporary selection for this modal
//    @State private var tempDept: String = ""
//    @State private var tempDoctor: String = ""

//    var filteredDoctors: [DoctorAppointment] {
//        let filtered = viewModel.doctorAppointments.filter { appt in
//            (selectedFilter == "All" || appt.department == selectedFilter) &&
//            (searchText.isEmpty || appt.name.localizedCaseInsensitiveContains(searchText))
//        }

//        // Deduplicate by doctor name
//        var seenNames = Set<String>()
//        let distinct = filtered.filter { appt in
//            if seenNames.contains(appt.name) { return false }
//            seenNames.insert(appt.name)
//            return true
//        }

//        // Sort by department first, then by name
//        return distinct.sorted { (a, b) in
//            if a.department == b.department {
//                return a.name < b.name
//            } else {
//                return a.department < b.department
//            }
//        }
//    }


//    var uniqueDepartments: [String] {
//        Array(Set(viewModel.doctorAppointments.map { $0.department })).sorted()
//    }

//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {

//                // Search + Department filter
//                HStack {
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                        TextField("Search doctor...", text: $searchText)
//                            .autocapitalization(.words)
//                    }
//                    .padding(8)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)

//                    Menu {
//                        Button("All") { selectedFilter = "All" }
//                        ForEach(uniqueDepartments, id: \.self) { dept in
//                            Button(dept) { selectedFilter = dept }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedFilter)
//                            Image(systemName: "chevron.down")
//                        }
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 6)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    }
//                }
//                .padding()

//                // Doctor list
//                List(filteredDoctors) { doctor in
//                    let isSelected = (tempDoctor == doctor.name && tempDept == doctor.department)

//                    HStack {
//                        Text(doctor.department)
//                            .font(.subheadline)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Text(" - ")
//                            .font(.subheadline)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Text(doctor.name)
//                            .font(.subheadline)
//                            .foregroundColor(Color(hex: "#0F0E46"))
//                        Spacer()
//                        if isSelected {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(Color(hex: "#0F0E46"))
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        if isSelected {
//                            tempDoctor = ""
//                            tempDept = ""
//                        } else {
//                            tempDoctor = doctor.name
//                            tempDept = doctor.department
//                        }
//                    }
//                }
//                .listStyle(.plain)
//            }
//            .navigationTitle("Select Doctor")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Select") {
//                        selectedDept = tempDept
//                        selectedDoctor = tempDoctor
//                        dismiss()
//                    }
//                    .disabled(tempDoctor.isEmpty)
//                }
//            }
//            .onAppear {
//                tempDept = selectedDept
//                tempDoctor = selectedDoctor
//            }
//        }
//    }
// }


// // Protocol to unify appointments
// protocol TimeSelectable: Identifiable {
//    var startTime: Date { get }
//    var endTime: Date { get }
//    var displayText: String { get }       // optional description, e.g., available slots
//    var isSelectable: Bool { get }        // enable/disable selection
// }

// // Conform ServiceAppointment
// extension ServiceAppointment: TimeSelectable {
//    var displayText: String { "\(availableSlots)/3 Slot Available" }
//    var isSelectable: Bool { availableSlots > 0 }
// }

// // Conform DoctorAppointment (you can tweak displayText as needed)
// extension DoctorAppointment: TimeSelectable {
//    var endTime: Date { startTime.addingTimeInterval(30 * 60) } // assume 30min slot
//    var displayText: String { "\(availableSlots)/3 Slot Available" }
//    var isSelectable: Bool { true }         // assume always selectable
// }

// // Unified TimePickerModal
// struct TimePickerModal<T: TimeSelectable>: View {
//    let appointments: [T]
//    @Binding var selectedAppointment: T?
//    @Binding var isPresented: Bool
//    var onConfirm: () -> Void

//    @State private var tempSelection: T?

//    var body: some View {
//        NavigationStack {
//            List(appointments) { appointment in
//                Button {
//                    tempSelection = appointment
//                } label: {
//                    HStack {
//                        Text("\(timeString(appointment.startTime)) - \(timeString(appointment.endTime))")
//                            .font(.subheadline)
//                            .foregroundColor(.black)
//                        Spacer()
//                        Text(appointment.displayText)
//                            .font(.subheadline)
//                            .foregroundColor(appointment.isSelectable ? .black : .red)
//                        if tempSelection?.id == appointment.id {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(Color(hex: "#0F0E46"))
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .disabled(!appointment.isSelectable)
//            }
//            .listStyle(.plain)
//            .navigationTitle("Pick a Time")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        isPresented = false
//                        tempSelection = nil
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Confirm") {
//                        selectedAppointment = tempSelection
//                        onConfirm()
//                        isPresented = false
//                    }
//                    .disabled(tempSelection == nil)
//                }
//            }
//        }
//        .presentationDetents([.height(200)])
//    }

//    private func timeString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
// }






// // MARK: - Small Cards
// struct AppointmentCard_Service: View {
//    let appt: ServiceAppointment
   
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                // Date
//                Text(dateString(appt.startTime))
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                Spacer()
//                // Service Name
//                Text(appt.unit)
//                    .font(.subheadline)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//            }
           
//            HStack {
//                // Time
//                Text(timeString(appt.startTime))
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                Spacer()
//                // Package Name
//                Text(appt.name)
//                    .font(.subheadline)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 6)
//                    .background(Color(hex: "#FFE4E4"))
//                    .cornerRadius(3)
                   
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
//    }
   
//    private func dateString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd MMMM yyyy"
//        return formatter.string(from: date)
//    }
   
//    private func timeString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH.mm"
//        return formatter.string(from: date)
//    }
// }

// struct AppointmentCard_Doctor: View {
//    let appt: DoctorAppointment

//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                // Date
//                Text(dateString(appt.date))
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                Spacer()
//                // Doctor Name
//                Text(appt.name)
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
//            }
           
//            HStack {
//                // Time
//                Text(timeString(appt.startTime))
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                Spacer()
//                // Department
//                Text("\(appt.department)")
//                    .font(.subheadline)
//                    .foregroundColor(Color(hex: "#0F0E46"))
//                    .padding(.vertical, 3)
//                    .padding(.horizontal, 6)
//                    .background(Color(hex: "#FFE4E4"))
//                    .cornerRadius(3)
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
//    }
   
//    private func dateString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd MMMM yyyy"
//        return formatter.string(from: date)
//    }
   
//    private func timeString(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH.mm"
//        return formatter.string(from: date)
//    }
// }
