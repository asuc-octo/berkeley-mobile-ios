//
//  HasOpenClosedStatus.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/17/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

/// Successor of `HasOpenTimes`. In the future, we should migrate to using `HasOpenClosedStatus` instead of `HasOpenTimes` with `WeeklyHours`.
protocol HasOpenClosedStatus: Identifiable {
    var hours: [DateInterval] { get }
    var isOpen: Bool { get set }
    var id: String { get }
}

extension HasOpenClosedStatus {
    mutating func updateIsOpenStatus(_ date: Date) {
        isOpen = hours.contains(where: { $0.contains(date) })
    }
}
