//
//  CampusMapModel.swift
//  berkeleyMobileiOS
//
//  Created by RJ Pimentel on 1/11/19.
//  Copyright © 2019 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CampusMapModel {
    var locations: [Location] = []
    var shortcutButtons: [UIButton] = []
    static var shortcutsAndIconNames: [(String, String)] = [
        ("Printers", "printer-icon"),
        ("Water Fountains", "water-bottle-icon"),
        ("Mental Health Resources", "mental-health-icon"),
        ("Microwaves", "microwave-icon"),
        ("Nap Pods", "nap-pods-icon"),
        ("Ford Go Bikes", "bike-icon")
    ]
    
    static var shortcutToIconNames: [String: String] = [
        "Printer": "printer-icon",
        "Water Fountain": "water-bottle-icon",
        "Mental Health Resource": "mental-health-icon",
        "Microwave": "microwave-icon",
        "Nap Pod": "nap-pods-icon",
        "Ford Go Bike": "bike-icon"
    ]
    
    
    func search(for query: String) -> [Location] {
        let formattedQuery = CampusMapModel.formatQuery(string: query)
        if CampusMapDataSource.completedFetchingLocations {
            if let locations =  CampusMapDataSource.queriesToLocations[formattedQuery] {
                return locations
            }
        }
        return []
    }
    
    static func formatQuery(string: String) -> String {
        let formatted = string.lowercased()
        return formatted
    }
}

class Location: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: String
    var numAttributes: Int = 3
    
    var moreInfo: String? = nil
    var notes: String? = nil
    var open_close_array: [Any]? = nil
    var phone: String? =  nil
    
    
    init(title: String, subtitle: String, coordinates: (Double, Double)) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: coordinates.0, longitude: coordinates.1)
        self.type = subtitle
    }
    
    func isOpen() -> Bool? {
        if let openTimes = open_close_array {
            
        }
        return nil
    }
    
}

