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
            _ = try await database.save(record)
            print("✅ Synced \(T.self): \(record.recordID.recordName)")
        } catch {
            print("❌ Failed to sync \(T.self): \(error.localizedDescription)")
            throw error
        }
    }
    
    // Generic method to delete a record from CloudKit
    func delete<T>(recordID: CKRecord.ID, for type: T.Type) async throws {
        do {
            _ = try await database.deleteRecord(withID: recordID)
            print("✅ Deleted \(T.self): \(recordID.recordName)")
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
}
