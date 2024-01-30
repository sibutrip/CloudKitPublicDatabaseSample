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
        case loading, loaded
    }
    
    private let ckService = CloudKitService()
    
    @Published var events: [Event] = []
    @Published var appState: AppState = .loaded
    
    func fetchEvents() async throws {
        self.events = try await ckService.fetchEvents()
    }
    
    func saveNewEvent(withTitle title: String, venue: String, description: String, date: Date) async throws {
        let event = Event(title: title, venue: venue, description: description, date: date)
        try await ckService.saveEvent(event)
        events.append(event)
    }
    
    func delete(_ eventToDelete: Event) async throws {
        try await ckService.deleteEvent(eventToDelete)
        events = events.filter { storedEvents in
            return storedEvents.id != eventToDelete.id
        }
    }
    
    func update(_ updatedEvent: Event) async throws {
        try await ckService.updateEvent(updatedEvent)
        var updatedEvents = events.filter { storedEvents in
            return storedEvents.id != updatedEvent.id
        }
        updatedEvents.append(updatedEvent)
        self.events = updatedEvents
    }
}
