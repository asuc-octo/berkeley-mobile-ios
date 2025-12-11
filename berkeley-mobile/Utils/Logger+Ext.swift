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
    
    static let guidesViewModel = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: GuidesViewModel.self)
    )
    
    static let openClosedStatusManager = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: OpenClosedStatusManager.self)
    )
    
    static let feedbackFormConfig = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedbackFormViewModel.self)
    )
    
    static let homeDrawerPinViewModel = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HomeDrawerPinViewModel.self)
    )
}
