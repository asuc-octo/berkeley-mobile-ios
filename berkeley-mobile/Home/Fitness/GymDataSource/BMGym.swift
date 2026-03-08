//
//  BMGym.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

struct BMGym: HomeDrawerSectionRowItemType, CanFavorite, HasPhoneNumber, HasOpenTimes {
    
    var id: String { docID }
    var docID: String

    // MARK: SearchIitem

    var icon: UIImage?
    
    var searchName: String {
        return name
    }

    // MARK: HasLocation

    var latitude: Double?
    var longitude: Double?
    @Display var address: String?

    // MARK: HasImage
    
    let imageURL: URL?

    // MARK: HasPhoneNumber

    @Display var phoneNumber: String?

    // MARK: HasOpenTimes

    let weeklyHours: WeeklyHours?

    // MARK: CanFavorite

    var isFavorited: Bool = false

    // MARK: Additional Properties

    /// The display-friendly name of this BMGym.
    @Display var name: String

    /// An optional URL linking to a website for this Fitness location.
    var website: URL?

    /// A display-friendly string description of this Fitness location.
    @Display var description: String?

    init(name: String,
         description: String?,
         address: String?,
         phoneNumber: String?,
         imageLink: String?,
         weeklyHours: WeeklyHours?,
         link: String?,
         documentID: String
    ) {
        self.address = address?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description
        self.phoneNumber = phoneNumber
        self.weeklyHours = weeklyHours
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageURL = URL(string: imageLink ?? "")
        self.icon = UIImage(systemName: "figure.walk")
        self.website = URL(string: link ?? "")
        self.docID = documentID
    }
}

extension BMGym: Hashable {
    static func == (lhs: BMGym, rhs: BMGym) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
