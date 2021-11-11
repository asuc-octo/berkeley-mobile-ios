//
//  SearchItem.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

protocol SearchItem: HasName {

    var searchName: String { get }
    var location: (Double, Double) { get }
    /// The display-friendly address to display for search results.
    var locationName: String { get }
    /// Icon to display when pin is dropped on map search.
    var icon: UIImage? { get }
}

// Default values for `location` and `locationName`, can be overridden.
extension SearchItem where Self: HasLocation {
    var location: (Double, Double) {
        return (latitude ?? 0, longitude ?? 0)
    }

    var locationName: String {
        return address ?? Strings.defaultLocationBerkeley
    }
}
