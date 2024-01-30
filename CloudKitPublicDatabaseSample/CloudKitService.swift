//
//  CloudKitService.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import CloudKit

class CloudKitService {
    
    enum CloudKitServiceError: Error {
        case recordNotInDatabase
    }
    
    private let container = CKContainer(identifier: "iCloud.com.CoryTripathy.CloudKitShare")
    private lazy var database = container.publicCloudDatabase
    
    public func saveEvent(_ event: Event) async throws {
        let record = CKRecord(recordType: "Event", recordID: .init(recordName: event.id))
        record["title"] = event.title
        record["venue"] = event.venue
        record["description"] = event.description
        record["date"] = event.date
        
        try await database.save(record)
    }
  
    public func fetchEvents() async throws -> [Event] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Event", predicate: predicate)
        let (matchResults, _) = try await database.records(matching: query)
        let results = matchResults.map { matchResult in
            return matchResult.1
        }
        let records = results.compactMap { result in
            try? result.get()
        }
        let events: [Event] = records.compactMap { record in
            guard let title = record["title"] as? String,
                  let venue = record["venue"] as? String,
                  let description = record["description"] as? String,
                  let date = record["date"] as? Date else {
                return nil
            }
            return Event(
                title: title,
                venue: venue,
                description: description,
                date: date)
        }
        return events
    }
  
    public func updateEvent(_ event: Event) async throws {
        guard let fetchedRecord = try? await database.record(for: .init(recordName: event.id)) else {
            throw CloudKitServiceError.recordNotInDatabase
        }
        
        let record = CKRecord(recordType: "Event", recordID: fetchedRecord.recordID)
        record["title"] = event.title
        record["venue"] = event.venue
        record["description"] = event.description
        record["date"] = event.date
        
        _ = try await database.modifyRecords(saving: [record], deleting: [])
    }
  
    public func deleteEvent(_ event: Event) async throws {
        guard let fetchedRecord = try? await database.record(for: .init(recordName: event.id)) else {
            throw CloudKitServiceError.recordNotInDatabase
        }
        
        _ = try await database.modifyRecords(saving: [], deleting: [fetchedRecord.recordID])
    }
}
