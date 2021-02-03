//
//  AddClass.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/3/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

struct AddClassParams: Encodable {
    let email: String
    let cryptohash: String
    let className: String
    let size: Int
    let env: String

    enum CodingKeys: String, CodingKey {
        case email = "user_email", cryptohash = "secret_token",
             className = "class_name", size, env
    }

    init?(email: String, cryptohash: String, prefs: StudyPactPreference) {
        guard let className = prefs.className,
              let size = prefs.numberOfPeople,
              let isVirtual = prefs.isVirtual else {
            return nil
        }
        self.email = email
        self.cryptohash = cryptohash
        self.className = className
        self.size = size
        self.env = isVirtual ? "Virtual" : "In Person"
    }
}
