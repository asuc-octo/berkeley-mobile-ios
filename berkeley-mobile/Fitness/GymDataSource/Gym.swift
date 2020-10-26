//
//  Gym.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

class Gym: SearchItem, HasLocation, CanFavorite, HasPhoneNumber, HasImage, HasOpenTimes, HasOccupancy {

    // MARK: SearchIitem

    var icon: UIImage?
    
    var searchName: String {
        return name
    }

    // MARK: HasLocation

    var latitude: Double?
    var longitude: Double?
    let address: String?

    // MARK: HasImage
    
    let imageURL: URL?

    // MARK: HasPhoneNumber

    let phoneNumber: String?

    // MARK: HasOpenTimes

    let weeklyHours: WeeklyHours?

    // MARK: HasOccupancy

    var occupancy: Occupancy?

    // MARK: CanFavorite

    var isFavorited: Bool = false

    // MARK: Additional Properties

    /// The display-friendly name of this Gym.
    let name: String

    /// An optional URL linking to a website for this Fitness location.
    var website: URL?

    /// A display-friendly string description of this Fitness location.
    let description: String?

    init(name: String, description: String?, address: String?, phoneNumber: String?, imageLink: String?, weeklyHours: WeeklyHours?, link: String?) {
        self.address = address?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "�", with: "")
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(named: "Walk")
        self.website = URL(string: link ?? "")
    }

}

