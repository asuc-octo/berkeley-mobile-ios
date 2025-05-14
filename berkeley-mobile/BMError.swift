//
//  BMError.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/14/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

enum BMError: Error {
    case eventAlreadyAddedInCalendar
    case insufficientAccessToCalendar
    case mayExistedInCalendarAlready
}

extension BMError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .insufficientAccessToCalendar:
            return NSLocalizedString("Insufficient permissions to access your calendar. Please go to Settings to allow calendar access.", comment: "Insufficent Permissions Error")
        case .eventAlreadyAddedInCalendar:
            return NSLocalizedString("Event has already been added to your calendar.", comment: "Event Already Added To Calendar Error")
        case .mayExistedInCalendarAlready:
            return NSLocalizedString("Event may already have been added to your calendar.", comment: "Event May Already Been Added Error")
        }
    }
}
