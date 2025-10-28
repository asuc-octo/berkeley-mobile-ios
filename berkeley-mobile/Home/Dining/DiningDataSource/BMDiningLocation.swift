//
//  BMDiningLocation.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/24/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Firebase
import FirebaseCore
import UIKit

/// `BMDiningHall` is the representation for a dining hall used throughout the app. We fetch the dining halls from Firebase as `BMDininghallDocument` and convert them into `BMDiningHall`.
struct BMDiningHall: SearchItem, HasLocation, HasPhoneNumber, HasImage, HasOpenClosedStatus, Equatable, Hashable, Identifiable {
    var id: String = ""
    var icon: UIImage?
    var searchName: String { return name }
    var imageURL: URL?
    var name: String
    var address: String?
    var phoneNumber: String?
    var isOpen = false

    /// A private array of `String` representation of all the open time interval periods
    private(set) var _hours: [String]
    var hours: [DateInterval] {
        return _hours.compactMap { $0.convertToDateInterval() }
    }
    
    var meals: [BMMeal.BMMealType: BMMeal]

    var latitude: Double?
    var longitude: Double?
    
    init(
        name: String,
        address: String?,
        phoneNumber: String?,
        imageLink: String?,
        meals: [BMMeal.BMMealType: BMMeal] = [:],
        hours: [String],
        latitude: Double?,
        longitude: Double?,
        documentID: String = ""
    ) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.imageURL = URL(string: imageLink ?? "")
        self.meals = meals
        self._hours = hours
        self.latitude = latitude
        self.longitude = longitude
        self.icon = UIImage(systemName: "fork.knife")
        self.id = documentID
    }
}


// MARK: - Firebase Decode Struct Representations

struct BMDiningHallDocument: Codable, Identifiable {
    @DocumentID var id: String?
    let diningHall: BMDiningHallRepresentation
    let scrapedAt: Timestamp?
}

struct BMDiningHallRepresentation: Codable {
    let name: String
    let status: String
    let openHourPeriods: [String]
    let serveDate: String
    let meals: [BMMeal]
    
    enum CodingKeys: String, CodingKey {
        case name = "locationName"
        case status
        case openHourPeriods = "timeSpans"
        case serveDate
        case meals
    }
    
    func getMealsTypeDict() -> [BMMeal.BMMealType: BMMeal] {
        var dict: [BMMeal.BMMealType: BMMeal] = [:]
        meals.forEach { meal in
            dict[meal.mealType] = meal
        }
        return dict
    }
}

struct BMMeal: Codable, Hashable {
    enum BMMealType: String, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case other = "Other"
    }

    let mealType: BMMealType
    let mealTypeName: String
    let time: String?
    let categoriesAndMenuItems: [BMMealCategory]
    
    enum CodingKeys: String, CodingKey {
        case mealType = "meal"
        case mealTypeName = "rawTitle"
        case time
        case categoriesAndMenuItems
    }
}

struct BMMealCategory: Codable, Hashable {
    let categoryName: String
    let menuItems: [BMMenuItem]
}

struct BMMenuItem: Codable, Hashable {
    let name: String
    let icons: [BMMealIcon]
    let menuId: String?
    let itemId: String?
    let dataLocation: String?
}

struct BMMealIcon: Codable, Hashable {
    let name: String
    let iconURL: String
}

/// `BMDiningHallAdditionalData` includes static data not scrapable from the dining hall menus website
struct BMDiningHallAdditionalData: Codable {
    let name: String
    let address: String
    let pictureURL: String?
    let latitude: Double
    let longitude: Double
    let description: String?
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case address
        case pictureURL = "picture"
        case latitude
        case longitude
        case description
        case phoneNumber = "phone"
    }
}
