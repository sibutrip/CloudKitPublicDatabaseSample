//
//  Event.swift
//  CloudKitPublicDatabaseSample
//
//  Created by Cory Tripathy on 1/30/24.
//

import CoreLocation

struct Event: Identifiable {
    let id: String
    var title: String
    var venue: String
    var description: String
    var date: Date
  
    init(id: String = UUID().uuidString, title: String, venue: String, description: String, date: Date) {
        self.id = id
        self.title = title
        self.venue = venue
        self.description = description
        self.date = date
    }
    
    static var sampleEvents = [
        Event(title: "My Concert", venue: "The Club", description: "We're playing some of our greatest hits.", date: Date()),
        Event(title: "Baby Shower", venue: "Mom's House", description: "Come wash our baby, they rolled in the mud and we need help cleaning them up.", date: Date()),
    ]
}
