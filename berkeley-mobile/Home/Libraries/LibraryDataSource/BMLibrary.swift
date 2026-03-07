//
//  BMLibrary.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import MapKit
import UIKit

struct BMLibrary: HomeDrawerSectionRowItemType, CanFavorite, HasPhoneNumber, HasOpenTimes {
    var id: String { docID }
    var docID: String
    
    var searchName: String {
        return name
    }
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return address ?? "Berkeley, CA"
    }
    
    var icon: UIImage?
    
    static func displayName(pluralized: Bool) -> String {
        return "Librar" + (pluralized ? "ies" : "y")
    }
    
    @Display var name: String
    let imageURL: URL?
    
    var isFavorited: Bool = false

    @Display var description: String?
    @Display var address: String?
    @Display var phoneNumber: String?
    let weeklyHours: WeeklyHours?
    var weeklyByAppointment:[Bool]
    var latitude: Double?
    var longitude: Double?
    
    init(name: String,
         description: String?,
         address: String?,
         phoneNumber: String?,
         weeklyHours: WeeklyHours?,
         weeklyByAppointment:[Bool],
         imageLink: String?, latitude: Double?,
         longitude: Double?,
         documentID: String = ""
    ) {
        self.description = description
        self.address = address
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.weeklyByAppointment = weeklyByAppointment
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(systemName: "text.book.closed")
        self.docID = documentID
    }
}

extension BMLibrary: Hashable {
    static func == (lhs: BMLibrary, rhs: BMLibrary) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

