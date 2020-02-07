//
//  MapPlacemark.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

class MapPlacemark {
    
    var location: CLLocation?
    var searchName: String?
    var locationName: String?
    
    init(loc: CLLocation, name: String?, locName: String?) {
        location = loc
        searchName = name
        locationName = locName
    }
    
//    let geocoder = CLGeocoder()
//    geocoder.reverseGeocodeLocation(cl) { (places, error) in
//        if error == nil {
//            for p in places ?? [] {
//                print(p.name)
//                print(placemarks.count)
//                placemarks.append(p)
//            }
//        } else {
//
//        }
//    }
    
}
