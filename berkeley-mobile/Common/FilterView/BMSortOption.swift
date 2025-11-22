//
//  BMSortOption.swift
//  berkeley-mobile
//
//  Created by Ananya Dua on 11/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

enum BMSortOption: String, CaseIterable, Identifiable {
    case nameAsc
    case nameDesc
    case distanceAsc
    case distanceDesc
    case openFirst
    case closedFirst
    
    var id: String { rawValue }
    
    var displayTitle: String {
        switch self {
        case .nameAsc: return "Name (A → Z)"
        case .nameDesc: return "Name (Z → A)"
        case .distanceAsc: return "Closest"
        case .distanceDesc: return "Furthest"
        case .openFirst: return "Open Times"
        case .closedFirst: return "Close Times"
        }
    }
}
