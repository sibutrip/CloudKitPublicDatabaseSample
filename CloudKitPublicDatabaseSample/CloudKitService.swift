//
//  CloudKitService.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import CloudKit

class CloudKitService {
    let container = CKContainer(identifier: "iCloud.com.CoryTripathy.CloudKitShare")
    lazy var database = container.publicCloudDatabase
    public func saveEvent(_ event: Event) async throws { }
    public func fetchEvents() -> [Event] async throws { }
    public func updateEvent(_ event: Event) async throws { }
    public func deleteEvent(_ event: Event) async throws { }
}
