//
//  CloudKitService.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import CloudKit

class CloudKitService {
    
    /// Errors that could be thrown from CloudKitService methods.
    enum CloudKitServiceError: Error {
        case recordNotInDatabase
    }
    
    /// The iCloud (CloudKit) container that holds our app's data.
    private let container = CKContainer(identifier: "iCloud.com.CoryTripathy.CloudKitShare")
    
    /// The public database, where all iCloud users can read and write data.
    /// - Note: It's our job as developers to control access to the data in this
    ///         database. Our app's methods will provide the security that
    ///         will only allow users access to the data they are allowed to see.
    ///         When using the public database, be careful to only fetch data
    ///         that a specific user is allowed to see.
    private lazy var database = container.publicCloudDatabase
    
    /// Saves a user-created `Event` to the public iCloud database.
    ///
    /// - Parameter event: The event to save.
    /// - Throws: Errors contacting iCloud or saving the event.
    public func saveEvent(_ event: Event) async throws {
        // Make a CKRecord, which is a type CloudKit is able to store.
        let record = CKRecord(recordType: "Event", recordID: .init(recordName: event.id))
        
        // Store the properties of our Event as fields in the CKRecord
        // (CKRecord works like a dictionary, with keys and values.)
        record["title"] = event.title
        record["venue"] = event.venue
        record["description"] = event.description
        record["date"] = event.date
        
        // Try to save the CKRecord of our event to the iCloud database,
        // and wait for this operation to occur.
        try await database.save(record)
    }
    
    /// Get events from the public iCloud database.
    ///
    /// - Returns: An array of all events in the iCloud public database.
    /// - Throws: Errors contacting iCloud or fetching events.
    /// - Note: If the public database contains lots of events, this method may not
    ///         return every single event in the database. As your database gets
    ///         larger, consider using `NSPredicate` to filter for specific events,
    ///         or `CKQueryOperation.Cursor` to fetch lots of events in a
    ///         multi-step operation.
    public func fetchEvents() async throws -> [Event] {
        // NSPredicate is like a filter, and this one always returns
        // true, which means we every Event matches the filter, and
        // we will receive all of them. (or, as many as possible)
        let predicate = NSPredicate(value: true)
        
        // CKQuery defines what type we are looking for, and which
        // filter(s) to apply.
        let query = CKQuery(recordType: "Event", predicate: predicate)
        
        // Try to get the CKRecords from the database matching our query,
        // and wait for this operation to occur.
        let (matchResults, _) = try await database.records(matching: query)
        
        // Get the results from the match results.
        let results = matchResults.map { matchResult in
            return matchResult.1
        }
        
        // Get the actual CKRecords from the results, discarding any that
        // cannot be retrieved.
        let records = results.compactMap { result in
            try? result.get()
        }
        
        // Take the CKRecords, and turn them into events, discarding any
        // that don't have a complete set of properties.
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
    
    /// Updates the given event with new data.
    ///
    /// - Parameter event: The event to update, containing the new data, but still with the same `id`.
    /// - Throws: Errors contacting iCloud or updating the event.
    public func updateEvent(_ event: Event) async throws {
        // Try to get the existing Event as a CKRecord.
        guard let fetchedRecord = try? await database.record(for: .init(recordName: event.id)) else {
            // If we are trying to update an event that doesn't exist, throw an error.
            throw CloudKitServiceError.recordNotInDatabase
        }
        
        // Create a new record with the same ID as the existing record.
        let record = CKRecord(recordType: "Event", recordID: fetchedRecord.recordID)
        
        // Update the new record's properties.
        record["title"] = event.title
        record["venue"] = event.venue
        record["description"] = event.description
        record["date"] = event.date
        
        // Try to modify the record in the CloudKit database, and wait for
        // this operation to occur.
        _ = try await database.modifyRecords(saving: [record], deleting: [])
    }
  
    /// Deletes the given event from the iCloud database.
    ///
    /// - Parameter event: The event to delete.
    /// - Throws: Errors contacting iCloud or deleting the event.
    public func deleteEvent(_ event: Event) async throws {
        // Try to get the existing Event as a CKRecord.
        guard let fetchedRecord = try? await database.record(for: .init(recordName: event.id)) else {
            // If we are trying to delete an event that doesn't
            // exist, throw an error.
            throw CloudKitServiceError.recordNotInDatabase
        }
        
        // Try to delete the record in the CloudKit database, and wait for
        // this operation to occur.
        _ = try await database.modifyRecords(saving: [], deleting: [fetchedRecord.recordID])
    }
}
