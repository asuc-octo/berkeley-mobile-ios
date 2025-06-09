//
//  RecentSearchManager.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 4/21/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

struct RecentSearchManager {
    private static let capacity = 7
    
    static func load() -> [CodableMapPlacemark] {
        if let saved = UserDefaults.standard.data(forKey: .recentSearches),
           let decoded = try? JSONDecoder().decode([CodableMapPlacemark].self, from: saved) {
                return decoded
        } else {
            return []
        }
    }
    
    static func add(_ placemark: MapPlacemark, to recentSearches: [CodableMapPlacemark]) -> [CodableMapPlacemark] {
        guard let codablePlacemark = placemark.toCodable() else {
            return recentSearches
        }
        
        var updatedRecentSearches = recentSearches

        if let existingIndex = updatedRecentSearches.firstIndex(where: { $0 == codablePlacemark }) {
            updatedRecentSearches.remove(at: existingIndex)
        }
        
        updatedRecentSearches.insert(codablePlacemark, at: 0)
        
        if updatedRecentSearches.count > capacity {
            updatedRecentSearches.removeLast()
        }
        
        return updatedRecentSearches
    }
    
    static func delete(at offsets: IndexSet, in recentSearches: [CodableMapPlacemark]) -> [CodableMapPlacemark] {
        guard let index = offsets.first else {
            return recentSearches
        }
        
        var updatedRecentSearches = recentSearches
        updatedRecentSearches.remove(at: index)
        return updatedRecentSearches
    }
    
    static func save(_ recentSearches: [CodableMapPlacemark]) {
        if let encodedRecentSearch = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encodedRecentSearch, forKey: .recentSearches)
        }
    }
}
