//
//  BMConstants.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import MapKit

struct BMConstants {
    static let doeGladeImage = UIImage(imageLiteralResourceName: "DoeGlade")
    
    
    // MARK: - Map
    
    static var mapBoundsRegion: MKCoordinateRegion {
        let fullMapCenter = CLLocationCoordinate2D(latitude: 37.76251429388581, longitude: -122.27164812506234)
        let fullMapSpan = MKCoordinateSpan(latitudeDelta: 0.8458437031956976, longitudeDelta: 0.6425468841745499)
        return MKCoordinateRegion(center: fullMapCenter, span: fullMapSpan)
    }
    static var berkeleyRegion: MKCoordinateRegion {
        let regionRadius: CLLocationDistance = 1000
        return MKCoordinateRegion(center: berkeleyLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    }
    static let berkeleyLocation = CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934))
    static let mapMaxZoomDistance: CLLocationDistance = 300000
    
    
    // MARK: - Firebase
    
    static let safetyLogsCollectionName = "Safety Logs"
    static let resourceCategoriesCollectionName = "Resource Categories"
}
