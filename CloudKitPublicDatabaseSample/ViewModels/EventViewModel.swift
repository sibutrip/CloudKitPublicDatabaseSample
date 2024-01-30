//
//  EventViewModel.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    
    enum AppState {
        case loading, loaded, failed(Error)
    }
    
    private let ckService = CloudKitService()
    
    @Published var events: [Event] = []
    @Published var appState: AppState = .loaded
    
    /// Fetches all `Event` records from CloudKit.
    ///
    /// Can throw an error if this Record type does not exist in the CloudKit console.
    func fetchEvents() async throws {
        appState = .loading
        do {
            self.events = try await ckService.fetchEvents()
            appState = .loaded
        } catch {
            appState = .failed(error)
        }
    }
    
    /// Saves new event to database
    /// - Parameters:
    ///   - title: Title for the `Event`'s `title` field.
    ///   - venue: Venue for the `Event`'s `venue` field.
    ///   - description: Description for the `Event`'s `description` field.
    ///   - date: Corresponding date of event for `date` field.
    ///
    ///   Throws an error if a record with this ID already exists in CloudKit, so make sure you're calling `update(_:)` when appropriate.
    func saveNewEvent(withTitle title: String, venue: String, description: String, date: Date) async throws {
        appState = .loading
        do {
            let event = Event(title: title, venue: venue, description: description, date: date)
            try await ckService.saveEvent(event)
            events.append(event)
            appState = .loaded
        } catch {
            appState = .failed(error)
        }
    }
    
    /// Deletes the `Event` with the matching ID from CloudKit.
    /// - Parameter eventToDelete: `Event` with the `id` matching the `CKRecord.ID` in CloudKit to delete.
    ///
    /// Make sure you're using best practices to ensure the appropriate users are deleting certain records.
    func delete(_ eventToDelete: Event) async throws {
        appState = .loading
        do {
            try await ckService.deleteEvent(eventToDelete)
            events = events.filter { storedEvents in
                return storedEvents.id != eventToDelete.id
            }
            appState = .loaded
        } catch {
            appState = .failed(error)
        }
    }
    
    /// Updates an existing event. Make sure you update the `Event` before calling this method, as every field in the exising `Event` record will be updated with this event's properties.
    /// - Parameter updatedEvent: Updated `Event` with an `id` matching the `CKRecord.ID` in CloudKit to update.
    ///
    /// This method will not add a new `Event` record if the event is not in CloudKit. Make sure you're calling `saveNewEvent(withTitle:venue:description:date:)` when appropriate.
    func update(_ updatedEvent: Event) async throws {
        appState = .loading
        do {
            try await ckService.updateEvent(updatedEvent)
            var updatedEvents = events.filter { storedEvents in
                return storedEvents.id != updatedEvent.id
            }
            updatedEvents.append(updatedEvent)
            self.events = updatedEvents
            appState = .loaded
        } catch {
            appState = .failed(error)
        }
    }
}
