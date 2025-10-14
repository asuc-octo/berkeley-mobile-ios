//
//  Logger+Ext.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import os

extension Logger {
    static let diningHallsViewModel = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: DiningHallsViewModel.self)
    )
}
