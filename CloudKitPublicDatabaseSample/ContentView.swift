//
//  ContentView.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var eventVM = EventViewModel()
    
    @State private var isShowingAddEvent = false
    
    var body: some View {
        NavigationStack {
            List {
                switch eventVM.appState {
                case .loading:
                    VStack {
                        ProgressView()
                        Text("Loading events...")
                            .font(.caption)
                    }
                    .listRowBackground(EmptyView())
                case .loaded:
                    ForEach(eventVM.events) { event in
                        eventRow(event)
                    }
                case .failed(let error):
                    Text("Error connecting to iCloud database: \(error.localizedDescription)")
                }
            }
            .navigationTitle("Cool Events")
            .toolbar {
                addEventButton
            }
            .sheet(isPresented: $isShowingAddEvent) {
                AddEventView(eventVM: eventVM)
            }
            .task {
                try? await eventVM.fetchEvents()
            }
            .refreshable {
                try? await eventVM.fetchEvents()
            }
        }
    }
}

extension ContentView {
    func eventRow(_ event: Event) -> some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.title.weight(.medium))
            Label(event.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                .font(.headline)
            Label(event.venue, systemImage: "location")
                .font(.headline)
            Text(event.description)
        }
    }
    
    var addEventButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                eventVM.appState = .loaded
                isShowingAddEvent.toggle()
            } label: {
                Label("Add event", systemImage: "calendar.badge.plus")
            }
        }
    }
}

#Preview {
    let eventVM = EventViewModel()
    let events = Event.sampleEvents
    eventVM.events = events
    return ContentView(eventVM: eventVM)
}
