//
//  MapPlacemark.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

// MARK: - MapPlacemark

class MapPlacemark {
    var location: CLLocation?
    var searchName: String?
    var locationName: String?
    var item: SearchItem?
    
    // initializer with a search item (library, dining hall, etc.) so that detail view can show details
    convenience init(loc: CLLocation, name: String?, locName: String?, item: SearchItem?) {
        self.init(loc: loc, name: name, locName: locName)
        self.item = item
    }
    
    init(loc: CLLocation, name: String?, locName: String?) {
        location = loc
        searchName = name
        locationName = locName
    }
}


// MARK: - CodableMapPlacemark

/// Light representation of MapPlacemark.
/// Used to save recent search data into UserDefaults.
struct CodableMapPlacemark: Codable, Equatable, Hashable {
    var latitude: Double
    var longitude: Double
    var searchName: String?
    var locationName: String?
}

extension MapPlacemark {
    func toCodable() -> CodableMapPlacemark? {
        guard let location else {
            return nil
        }
        
        return CodableMapPlacemark(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            searchName: searchName,
            locationName: locationName
        )
    }
    
    static func fromCodable(_ codablePlacemark: CodableMapPlacemark) -> MapPlacemark? {
        let delta = 0.0001 // threshold check in case of a precision loss when encoding/decoding
        
        guard let searchItem = DataManager.shared.searchable.first(where: {
            $0.searchName == codablePlacemark.searchName &&
            abs($0.location.0 - codablePlacemark.latitude) < delta &&
            abs($0.location.1 - codablePlacemark.longitude) < delta
        }) else {
            return nil
        }
        
        let location = CLLocation(latitude: searchItem.location.0, longitude: searchItem.location.1)
        
        return MapPlacemark(
            loc: location,
            name: searchItem.searchName,
            locName: searchItem.locationName,
            item: searchItem
        )
    }
}
