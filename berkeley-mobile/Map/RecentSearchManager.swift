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
        if let saved = UserDefaults.standard.data(forKey: .recentSearch),
           let decoded = try? JSONDecoder().decode([CodableMapPlacemark].self, from: saved) {
                return decoded
        } else {
            return []
        }
    }
    
    static func add(_ placemark: MapPlacemark, to recentSearch: [CodableMapPlacemark]) -> [CodableMapPlacemark] {
        guard let codablePlacemark = placemark.toCodable() else {
            return recentSearch
        }
        
        var updatedRecentSearch = recentSearch
        
        // remove if already exists
        if let index = updatedRecentSearch.firstIndex(where: { $0 == codablePlacemark }) {
            updatedRecentSearch.remove(at: index)
        }
        
        updatedRecentSearch.insert(codablePlacemark, at: 0)
        
        if updatedRecentSearch.count > capacity {
            updatedRecentSearch.removeLast()
        }
        
        return updatedRecentSearch
    }
    
    static func delete(at offsets: IndexSet, in recentSearch: [CodableMapPlacemark]) -> [CodableMapPlacemark] {
        guard let index = offsets.first else {
            return recentSearch
        }
        
        var updatedRecentSearch = recentSearch
        updatedRecentSearch.remove(at: index)
        return updatedRecentSearch
    }
    
    static func save(_ recentSearch: [CodableMapPlacemark]) {
        if let encodedRecentSearch = try? JSONEncoder().encode(recentSearch) {
            UserDefaults.standard.set(encodedRecentSearch, forKey: .recentSearch)
        }
    }
}
