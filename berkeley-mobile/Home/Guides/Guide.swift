//
//  Guide.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import FirebaseCore
import Foundation

struct Guide: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var curator: String?
    var places: [GuidePlace]
}

struct GuidePlace: Codable, HasImage, HasLocation, HasPhoneNumber, HasWebsite {
    var name: String
    var description: String
    
    var imageURL: URL?
    
    var phoneNumber: String?
    
    var address: String?
    var latitude: Double?
    var longitude: Double?
    
    var websiteURLString: String?
}
