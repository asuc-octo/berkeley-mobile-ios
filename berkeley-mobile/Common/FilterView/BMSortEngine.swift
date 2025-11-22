//
//  BMSortEngine.swift
//  berkeley-mobile
//
//  Created by Ananya Dua on 11/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

extension HasOpenClosedStatus {
    var todayInterval: DateInterval? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        return hours.first(where: { interval in
            interval.start >= today && interval.start < tomorrow
        })
    }

    var todayOpenTime: Date? {
        todayInterval?.start
    }

    var todayCloseTime: Date? {
        todayInterval?.end
    }
}

func sortItems<T: SearchItem & HasLocation & HasImage>(
    _ items: [T],
    by option: BMSortOption
) -> [T] {

    switch option {

    case .nameAsc:
        return items.sorted { $0.name < $1.name }

    case .nameDesc:
        return items.sorted { $0.name > $1.name }

    case .distanceAsc:
        return items.sorted {
            ($0.distanceToUser ?? .greatestFiniteMagnitude)
            < ($1.distanceToUser ?? .greatestFiniteMagnitude)
        }

    case .distanceDesc:
        return items.sorted {
            ($0.distanceToUser ?? .greatestFiniteMagnitude)
            > ($1.distanceToUser ?? .greatestFiniteMagnitude)
        }

    case .openFirst:
        return items.sorted {
            let a = ($0 as? any HasOpenClosedStatus)?.todayOpenTime ?? .distantFuture
            let b = ($1 as? any HasOpenClosedStatus)?.todayOpenTime ?? .distantFuture
            return a < b
        }

    case .closedFirst:
        return items.sorted {
            let a = ($0 as? any HasOpenClosedStatus)?.todayCloseTime ?? .distantFuture
            let b = ($1 as? any HasOpenClosedStatus)?.todayCloseTime ?? .distantFuture
            return a < b
        }
    }
}
