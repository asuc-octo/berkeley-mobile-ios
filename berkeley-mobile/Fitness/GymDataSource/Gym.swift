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
    
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }
    
    var locationName: String {
        return "Berkeley, CA"
    }
    
    var description: String {
        return ""
    }

    // MARK: HasLocation

    var latitude: Double?
    var longitude: Double?
    let address: String?

    // MARK: HasImage

    var image: UIImage?
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
    
    init(name: String, address: String?, phoneNumber: String?, imageLink: String?, weeklyHours: WeeklyHours?, link: String?) {
        self.address = address
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(named: "Walk")
        self.website = URL(string: link ?? "")
    }

}

