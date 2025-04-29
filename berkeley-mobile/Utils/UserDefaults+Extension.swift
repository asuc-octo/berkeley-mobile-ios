//
//  UserDefaults+Extension.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 4/21/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

enum UserDefaultsKeys: String {
    case numAppLaunchForFeedbackForm = "numAppLaunchForFeedbackForm"
    case academicEventsLastSavedDate = "academicEventsLastSavedDate"
    case campuswideEventsLastSavedDate = "campuswideEventsLastSavedDate"
    case recentSearches = "RecentSearch"
}

extension UserDefaults {
    func set<T>(_ value: T, forKey key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
    }
    
    func integer(forKey key: UserDefaultsKeys) -> Int {
        integer(forKey: key.rawValue)
    }
    
    func data(forKey key: UserDefaultsKeys) -> Data? {
        data(forKey: key.rawValue)
    }
}
