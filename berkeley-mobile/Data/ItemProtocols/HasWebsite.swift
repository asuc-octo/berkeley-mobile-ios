//
//  HasWebsite.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/28/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

protocol HasWebsite {
    var websiteURLString: String? { get }
}

extension HasWebsite {
    var hasWebsite: Bool {
        guard let websiteURLString else {
            return false
        }
        return !websiteURLString.isEmpty
    }
}
