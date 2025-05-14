//
//  Constants.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import UIKit

struct Constants {
    static let doeGladeImage = UIImage(imageLiteralResourceName: "DoeGlade")
}

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
            return NSLocalizedString("Event maybe have been added to your calendar already.", comment: "Event May Already Been Added Error")
        }
    }
}
