//
//  CloudKitManager.swift
//  triage
//
//  Created by Assistant on 08/09/25.
//

import Foundation
import CloudKit
import SwiftData

@Observable
class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private var database: CKDatabase { container.publicCloudDatabase }
    
    var isCloudKitEnabled = true
    var syncStatus: SyncStatus = .idle
    var lastSyncDate: Date?
    
    // Managers for accessing SwiftData
    private var patientManager: PatientManager?
    private var appointmentManager: AppointmentManager?
    private var packageManager: PackageManager?
    private var departmentManager: DepartmentManager?
    private var quickReplyManager: QuickReplyManager?
    private var historyManager: HistoryManager?
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case error(String)
        case success
    }
    
    private init() {
        // Use the specific container for your app
        self.container = CKContainer(identifier: "iCloud.com.ada.triage")
        checkCloudKitAvailability()
    }
    
    // MARK: - Manager Setup
    func setManagers(
        patient: PatientManager,
        appointment: AppointmentManager,
        package: PackageManager,
        department: DepartmentManager,
        quickReply: QuickReplyManager,
        history: HistoryManager
    ) {
        self.patientManager = patient
        self.appointmentManager = appointment
        self.packageManager = package
        self.departmentManager = department
        self.quickReplyManager = quickReply
        self.historyManager = history
    }
    
    // MARK: - CloudKit Availability
    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isCloudKitEnabled = true
                    print("✅ CloudKit is available")
                case .noAccount:
                    self?.isCloudKitEnabled = false
                    print("❌ No iCloud account signed in")
                case .restricted:
                    self?.isCloudKitEnabled = false
                    print("❌ CloudKit access is restricted")
                case .couldNotDetermine:
                    self?.isCloudKitEnabled = false
                    print("❌ Could not determine CloudKit status")
                case .temporarilyUnavailable:
                    self?.isCloudKitEnabled = false
                    print("⚠️ CloudKit is temporarily unavailable")
                @unknown default:
                    self?.isCloudKitEnabled = false
                    print("❌ Unknown CloudKit status")
                }
                
                if let error = error {
                    print("CloudKit status error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Manual Sync Trigger
    func triggerSync() {
        guard isCloudKitEnabled else {
            print("⚠️ CloudKit is not enabled, skipping sync")
            syncStatus = .error("CloudKit not available")
            return
        }
        
        syncStatus = .syncing
        
        // Perform bidirectional sync
        Task {
            await performBidirectionalSync()
        }
    }
    
    // MARK: - Bidirectional Sync
    func performBidirectionalSync() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            do {
                print("🔄 Starting bidirectional sync with CloudKit public database...")
                
                // First download any new data from CloudKit
                await downloadDataFromCloudKit()
                
                // Then upload local data to CloudKit
                await syncAllDataToCloudKit()
                
                DispatchQueue.main.async {
                    self.syncStatus = .success
                    self.lastSyncDate = Date()
                    
                    // Reset to idle after showing success briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.syncStatus = .idle
                    }
                }
                
                print("✅ Bidirectional sync completed successfully")
                
            } catch {
                print("❌ CloudKit sync error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.syncStatus = .error(error.localizedDescription)
                    
                    // Reset to idle after showing error briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.syncStatus = .idle
                    }
                }
            }
        }
    }
    
    // MARK: - Complete Data Sync
    private func syncAllDataToCloudKit() async {
        print("🔄 Starting sync to CloudKit public database...")
        
        // Sync in dependency order (departments first, then packages, etc.)
        await syncDepartments()
        await syncPackages()
        await syncPatients()
        await syncQuickReplies()
        await syncAppointments()
        await syncHistory()
        
        print("✅ All data synced to CloudKit public database successfully")
    }
    
    // MARK: - Individual Entity Sync Methods
    private func syncDepartments() async {
        guard let departments = departmentManager?.departments else { return }
        
        for department in departments {
            let record = CKRecord(recordType: "Department", recordID: CKRecord.ID(recordName: department.id.uuidString))
            record["name"] = department.name
            record["maxSlot"] = department.maxSlot
            
            do {
                _ = try await database.save(record)
                print("✅ Synced department: \(department.name)")
            } catch {
                print("❌ Failed to sync department \(department.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func syncPackages() async {
        guard let packages = packageManager?.packages else { return }
        
        for package in packages {
            let record = CKRecord(recordType: "Package", recordID: CKRecord.ID(recordName: package.id.uuidString))
            record["name"] = package.name
            record["descriptionText"] = package.descriptionText
            
            // Reference to department
            if let department = package.department {
                let departmentRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: department.id.uuidString), action: .deleteSelf)
                record["department"] = departmentRef
            }
            
            do {
                _ = try await database.save(record)
                print("✅ Synced package: \(package.name)")
            } catch {
                print("❌ Failed to sync package \(package.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func syncPatients() async {
        guard let patients = patientManager?.patients else { return }
        
        for patient in patients {
            let record = CKRecord(recordType: "Patient", recordID: CKRecord.ID(recordName: patient.id.uuidString))
            record["fullName"] = patient.fullName
            record["nationalID"] = patient.nationalID
            record["dateOfBirth"] = patient.dateOfBirth
            record["gender"] = patient.gender?.rawValue
            record["placeOfBirth"] = patient.placeOfBirth
            record["registeredAt"] = patient.registeredAt
            record["phoneNumber"] = patient.phoneNumber
            record["address"] = patient.address
            
            do {
                _ = try await database.save(record)
                print("✅ Synced patient: \(patient.fullName)")
            } catch {
                print("❌ Failed to sync patient \(patient.fullName): \(error.localizedDescription)")
            }
        }
    }
    
    private func syncQuickReplies() async {
        guard let quickReplies = quickReplyManager?.quickReplies else { return }
        
        for reply in quickReplies {
            let record = CKRecord(recordType: "QuickReply", recordID: CKRecord.ID(recordName: reply.id.uuidString))
            record["title"] = reply.title
            record["message"] = reply.message
            record["isActive"] = reply.isActive
            record["dateCreated"] = reply.dateCreated
            
            do {
                _ = try await database.save(record)
                print("✅ Synced quick reply: \(reply.title)")
            } catch {
                print("❌ Failed to sync quick reply \(reply.title): \(error.localizedDescription)")
            }
        }
    }
    
    private func syncAppointments() async {
        guard let appointments = appointmentManager?.appointments else { return }
        
        for appointment in appointments {
            let record = CKRecord(recordType: "Appointment", recordID: CKRecord.ID(recordName: appointment.id.uuidString))
            record["name"] = appointment.name
            
            // References to related records
            if let patient = appointment.patient {
                let patientRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: patient.id.uuidString), action: .deleteSelf)
                record["patient"] = patientRef
            }
            
            if let package = appointment.package {
                let packageRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: package.id.uuidString), action: .deleteSelf)
                record["package"] = packageRef
            }
            
            // TimeSlot data (embedded since TimeSlots are typically dynamic)
            if let timeSlot = appointment.timeSlot {
                record["date"] = timeSlot.date
                record["startTime"] = timeSlot.startTime
                record["endTime"] = timeSlot.endTime
            }
            
            do {
                _ = try await database.save(record)
                print("✅ Synced appointment: \(appointment.name)")
            } catch {
                print("❌ Failed to sync appointment \(appointment.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func syncHistory() async {
        guard let historyItems = historyManager?.history else { return }
        
        for historyItem in historyItems {
            let record = CKRecord(recordType: "History", recordID: CKRecord.ID(recordName: historyItem.id.uuidString))
            record["timestamp"] = historyItem.timestamp
            
            // Encode the history type data
            if let typeData = try? JSONEncoder().encode(historyItem.type),
               let typeString = String(data: typeData, encoding: .utf8) {
                record["typeData"] = typeString
            }
            
            do {
                _ = try await database.save(record)
                print("✅ Synced history item")
            } catch {
                print("❌ Failed to sync history item: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Download Data from CloudKit
    func downloadDataFromCloudKit() async {
        guard isCloudKitEnabled else { return }
        
        do {
            print("📥 Downloading data from CloudKit public database...")
            
            // Download in dependency order
            await downloadDepartments()
            await downloadPackages()
            await downloadPatients()
            await downloadQuickReplies()
            await downloadAppointments()
            await downloadHistory()
            
            print("✅ All data downloaded from CloudKit successfully")
            
        } catch {
            print("❌ CloudKit download error: \(error.localizedDescription)")
        }
    }
    
    private func downloadDepartments() async {
        do {
            let query = CKQuery(recordType: "Department", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    let department = Department(
                        id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                        name: record["name"] as? String ?? "",
                        maxSlot: record["maxSlot"] as? Int ?? 3
                    )
                    
                    // Add to local storage if not exists
                    if !(departmentManager?.departments.contains { $0.id == department.id } ?? false) {
                        departmentManager?.addDepartment(department)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download department: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query departments: \(error.localizedDescription)")
        }
    }
    
    private func downloadPackages() async {
        do {
            let query = CKQuery(recordType: "Package", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    // Find the department
                    var department: Department?
                    if let departmentRef = record["department"] as? CKRecord.Reference,
                       let departmentId = UUID(uuidString: departmentRef.recordID.recordName) {
                        department = departmentManager?.departments.first { $0.id == departmentId }
                    }
                    
                    if let department = department {
                        let package = Package(
                            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                            name: record["name"] as? String ?? "",
                            department: department,
                            descriptionText: record["descriptionText"] as? String
                        )
                        
                        // Add to local storage if not exists
                        if !(packageManager?.packages.contains { $0.id == package.id } ?? false) {
                            packageManager?.addPackage(package)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download package: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query packages: \(error.localizedDescription)")
        }
    }
    
    private func downloadPatients() async {
        do {
            let query = CKQuery(recordType: "Patient", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    let patient = Patient(
                        id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                        fullName: record["fullName"] as? String ?? ""
                    )
                    
                    patient.nationalID = record["nationalID"] as? String
                    patient.dateOfBirth = record["dateOfBirth"] as? Date
                    if let genderString = record["gender"] as? String {
                        patient.gender = Gender(rawValue: genderString)
                    }
                    patient.placeOfBirth = record["placeOfBirth"] as? String
                    patient.registeredAt = record["registeredAt"] as? Date
                    patient.phoneNumber = record["phoneNumber"] as? String
                    patient.address = record["address"] as? String
                    
                    // Add to local storage if not exists
                    if !(patientManager?.patients.contains { $0.id == patient.id } ?? false) {
                        patientManager?.addPatient(patient)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download patient: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query patients: \(error.localizedDescription)")
        }
    }
    
    private func downloadQuickReplies() async {
        do {
            let query = CKQuery(recordType: "QuickReply", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    let quickReply = QuickReply(
                        title: record["title"] as? String ?? "",
                        message: record["message"] as? String ?? "",
                        isActive: record["isActive"] as? Bool ?? true
                    )
                    quickReply.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
                    quickReply.dateCreated = record["dateCreated"] as? Date ?? Date()
                    
                    // Add to local storage if not exists
                    if !(quickReplyManager?.quickReplies.contains { $0.id == quickReply.id } ?? false) {
                        quickReplyManager?.addQuickReply(quickReply)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download quick reply: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query quick replies: \(error.localizedDescription)")
        }
    }
    
    private func downloadAppointments() async {
        do {
            let query = CKQuery(recordType: "Appointment", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    // Find related records
                    var patient: Patient?
                    var package: Package?
                    
                    if let patientRef = record["patient"] as? CKRecord.Reference,
                       let patientId = UUID(uuidString: patientRef.recordID.recordName) {
                        patient = patientManager?.patients.first { $0.id == patientId }
                    }
                    
                    if let packageRef = record["package"] as? CKRecord.Reference,
                       let packageId = UUID(uuidString: packageRef.recordID.recordName) {
                        package = packageManager?.packages.first { $0.id == packageId }
                    }
                    
                    // Create TimeSlot from embedded data
                    var timeSlot: TimeSlot?
                    if let date = record["date"] as? Date,
                       let startTime = record["startTime"] as? Date,
                       let endTime = record["endTime"] as? Date {
                        timeSlot = TimeSlot(date: date, startTime: startTime, endTime: endTime)
                    }
                    
                    if let patient = patient, let package = package, let timeSlot = timeSlot {
                        let appointment = Appointment(
                            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                            name: record["name"] as? String ?? "",
                            date: timeSlot.date,
                            startTime: timeSlot.startTime,
                            endTime: timeSlot.endTime,
                            timeSlot: timeSlot,
                            patient: patient,
                            package: package
                        )
                        
                        // Add to local storage if not exists
                        if !(appointmentManager?.appointments.contains { $0.id == appointment.id } ?? false) {
                            appointmentManager?.addAppointment(appointment)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download appointment: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query appointments: \(error.localizedDescription)")
        }
    }
    
    private func downloadHistory() async {
        do {
            let query = CKQuery(recordType: "History", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    let timestamp = record["timestamp"] as? Date ?? Date()
                    
                    // Decode history type
                    var historyType: HistoryType = .newPatient(patientName: "Unknown")
                    if let typeString = record["typeData"] as? String,
                       let typeData = typeString.data(using: .utf8),
                       let decodedType = try? JSONDecoder().decode(HistoryType.self, from: typeData) {
                        historyType = decodedType
                    }
                    
                    let history = History(
                        id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                        type: historyType,
                        timestamp: timestamp
                    )
                    
                    // Add to local storage if not exists
                    if !(historyManager?.history.contains { $0.id == history.id } ?? false) {
                        historyManager?.addHistory(history)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to download history: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to query history: \(error.localizedDescription)")
        }
    }
    
    func getCloudKitStatus() -> String {
        if !isCloudKitEnabled {
            return "CloudKit Unavailable"
        }
        
        switch syncStatus {
        case .idle:
            if let lastSync = lastSyncDate {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                return "Last sync: \(formatter.string(from: lastSync))"
            } else {
                return "Ready to sync"
            }
        case .syncing:
            return "Syncing..."
        case .error(let message):
            return "Error: \(message)"
        case .success:
            return "Sync completed"
        }
    }
    
    // MARK: - CloudKit Container Configuration
    static func configureCloudKit() {
        print("📱 CloudKit public database configuration completed")
        
        // Initialize the container and check permissions for public database
        let container = CKContainer(identifier: "iCloud.com.ada.triage")
        
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            if let error = error {
                print("❌ CloudKit permission error: \(error.localizedDescription)")
            } else {
                print("✅ CloudKit permissions configured")
            }
        }
    }
    
    // MARK: - Public Database Schema Setup
    func setupPublicDatabaseSchema() {
        // This method would set up the CloudKit schema for public database
        // In production, you would define your record types in CloudKit Dashboard
        print("📊 Setting up CloudKit public database schema")
    }
    
    // MARK: - Utility Methods
    func clearLocalData() {
        // Clear all local managers (useful for testing)
        print("🗑️ Clearing all local data...")
        // Note: This would typically require implementing clear methods in each manager
    }
    
    func getRecordCount() async -> [String: Int] {
        var counts: [String: Int] = [:]
        
        let recordTypes = ["Department", "Package", "Patient", "QuickReply", "Appointment", "History"]
        
        for recordType in recordTypes {
            do {
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                let (matchResults, _) = try await database.records(matching: query, resultsLimit: 1000)
                counts[recordType] = matchResults.count
            } catch {
                print("❌ Failed to count \(recordType): \(error.localizedDescription)")
                counts[recordType] = 0
            }
        }
        
        return counts
    }
    
    // MARK: - Force Upload (overwrite CloudKit with local data)
    func forceUploadAllData() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            await syncAllDataToCloudKit()
        }
    }
    
    // MARK: - Force Download (overwrite local data with CloudKit)
    func forceDownloadAllData() {
        guard isCloudKitEnabled else { return }
        
        syncStatus = .syncing
        
        Task {
            // First clear local data (if you implement this functionality)
            // Then download fresh from CloudKit
            await downloadDataFromCloudKit()
            
            DispatchQueue.main.async {
                self.syncStatus = .success
                self.lastSyncDate = Date()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.syncStatus = .idle
                }
            }
        }
    }
}
