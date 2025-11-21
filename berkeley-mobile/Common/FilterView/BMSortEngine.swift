//
//  BMSortMenuView.swift
//  berkeley-mobile
//
//  Created by Ananya Dua on 11/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

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
            let lOpen = ( $0 as? any HasOpenClosedStatus )?.isOpen ?? false
            let rOpen = ( $1 as? any HasOpenClosedStatus )?.isOpen ?? false
            
            if lOpen != rOpen {
                return lOpen && !rOpen
            }
            
            let d1 = $0.distanceToUser ?? .greatestFiniteMagnitude
            let d2 = $1.distanceToUser ?? .greatestFiniteMagnitude
            return d1 < d2
        }
        
    case .closedFirst:
        return items.sorted {
            let lOpen = ( $0 as? any HasOpenClosedStatus )?.isOpen ?? false
            let rOpen = ( $1 as? any HasOpenClosedStatus )?.isOpen ?? false
            
            if lOpen != rOpen {
                return !lOpen && rOpen
            }
            
            let d1 = $0.distanceToUser ?? .greatestFiniteMagnitude
            let d2 = $1.distanceToUser ?? .greatestFiniteMagnitude
            return d1 < d2
        }
    }
}
