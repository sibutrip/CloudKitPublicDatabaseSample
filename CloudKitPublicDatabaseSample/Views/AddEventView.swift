//
//  AddEventView.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Zoe Cutler on 1/30/24.
//

import SwiftUI

struct AddEventView: View {
    @ObservedObject var eventVM: EventViewModel
    
    @State private var title = ""
    @State private var venue = ""
    @State private var description = ""
    @State private var date = Date()
    
    @State private var isShowingError = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Info") {
                    TextField("Title", text: $title)
                    TextField("Venue", text: $venue)
                    TextField("Description", text: $description)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    switch eventVM.appState {
                    case .loading:
                        VStack {
                            ProgressView()
                            Text("Adding event...")
                                .font(.caption)
                        }
                    case .loaded:
                        Button("Add") {
                            addEvent()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(title.isEmpty || venue.isEmpty || description.isEmpty)
                    case .failed(let error):
                        Text("Error connecting to iCloud database: \(error.localizedDescription)")
                    }
                }
                .listRowBackground(EmptyView())
                
            }
            .navigationTitle("New Event")
            .alert("There was a problem adding an event. Please check your internet connection, and make sure you are signed in to iCloud and have iCloud Drive enabled.", isPresented: $isShowingError) {
                Button("dismiss", role: .cancel) { 
                    eventVM.appState = .loaded
                }
            }
        }
    }
    
    func addEvent() {
        Task {
            do {
                try await eventVM.saveNewEvent(withTitle: title, venue: venue, description: description, date: date)
                dismiss()
            } catch {
                isShowingError = true
            }
        }
    }
}

#Preview {
    AddEventView(eventVM: EventViewModel())
}
