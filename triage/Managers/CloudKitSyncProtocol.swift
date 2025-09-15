//
//  CloudKitSyncProtocol.swift
//  triage
//
//  Created by Assistant on 09/09/25.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    associatedtype ModelType
    
    func syncToCloudKit(_ item: ModelType) async
    func deleteFromCloudKit(_ item: ModelType) async
    func loadFromCloudKit() async
    func syncAllToCloudKit() async
}

// Helper class for CloudKit operations
class CloudKitHelper {
    static let shared = CloudKitHelper()
    
    private let container: CKContainer
    private var database: CKDatabase { container.publicCloudDatabase }
    
    private init() {
        self.container = CKContainer(identifier: "iCloud.com.ada.triage")
    }
    
    // Generic method to save a record to CloudKit
    func save<T>(_ record: CKRecord, for item: T) async throws {
        do {
            // Use modify operation which handles both insert and update
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record])
            modifyOperation.savePolicy = .allKeys // Always update all fields
            modifyOperation.qualityOfService = .userInitiated
            
            let (saveResults, _) = try await database.modifyRecords(
                saving: [record],
                deleting: [],
                savePolicy: .allKeys,
                atomically: false
            )
            
            if let result = saveResults[record.recordID] {
                switch result {
                case .success(let savedRecord):
                    print("✅ Synced \(T.self): \(savedRecord.recordID.recordName)")
                case .failure(let error):
                    print("❌ Failed to sync \(T.self): \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            print("❌ Failed to sync \(T.self): \(error.localizedDescription)")
            throw error
        }
    }
    
    // Generic method to delete a record from CloudKit
    func delete<T>(recordID: CKRecord.ID, for type: T.Type) async throws {
        do {
            let (_, deleteResults) = try await database.modifyRecords(
                saving: [],
                deleting: [recordID],
                savePolicy: .allKeys,
                atomically: false
            )
            
            if let result = deleteResults[recordID] {
                switch result {
                case .success():
                    print("✅ Deleted \(T.self): \(recordID.recordName)")
                case .failure(let error):
                    print("❌ Failed to delete \(T.self): \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            print("❌ Failed to delete \(T.self): \(error.localizedDescription)")
            throw error
        }
    }
    
    // Generic method to fetch records from CloudKit
    func fetchRecords(ofType recordType: String) async throws -> [(CKRecord.ID, Result<CKRecord, Error>)] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (matchResults, _) = try await database.records(matching: query)
        return Array(matchResults)
    }
    
    // Method to get all CloudKit record IDs for a specific type (for sync comparison)
    func fetchRecordIDs(ofType recordType: String) async throws -> Set<String> {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (matchResults, _) = try await database.records(matching: query)
        
        var recordNames = Set<String>()
        for (recordID, result) in matchResults {
            switch result {
            case .success(_):
                recordNames.insert(recordID.recordName)
            case .failure(_):
                // Skip failed records for now
                continue
            }
        }
        return recordNames
    }
}
