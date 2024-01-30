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
}
