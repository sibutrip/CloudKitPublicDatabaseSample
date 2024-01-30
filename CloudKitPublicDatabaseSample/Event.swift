//
//  Event.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import CoreLocation

struct Event {
    let id: String
    let title: String
    let venue: String
    let description: String
    let date: Date
  
    init(id: String = UUID().uuidString, title: String, venue: String, description: String, date: Date) {
        self.id = id
        self.title = title
        self.venue = venue
        self.description = description
        self.date = date
    }
}
