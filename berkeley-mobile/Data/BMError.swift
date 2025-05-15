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
            return NSLocalizedString("This event is already in your calendar.", comment: "Event Already Added To Calendar Error")
        case .mayExistedInCalendarAlready:
            return NSLocalizedString("This event may already be in your calendar. Please check for duplicates.", comment: "Event May Already Been Added Error")
        }
    }
}
