//
//  SearchAnnotation.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/21/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

class SearchAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var selectedFromTap: Bool = true
    
    var item: SearchItem
    
    init(item: SearchItem, location: CLLocationCoordinate2D) {
        self.item = item
        self.coordinate = location
    }
    
    func icon() -> UIImage {
        if let icon = item.icon {
            return icon
        } else {
            // TODO: Use default icon for search item with no icon
            return (UIImage(named: "Placemark")!)
        }
    }
    
    func color() -> UIColor {
        return UIColor(displayP3Red: 129/255, green: 164/255, blue: 255/255, alpha: 1.0)
    }
    
}
