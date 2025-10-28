//
//  RedirectionManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import MapKit

/// `RedirectionManager` redirects the user to other apps with information from Berkeley Mobile.
class RedirectionManager {
    func openInMaps(for place: HasLocation, withName name: String) {
        guard let latitude = place.latitude, let longitude = place.longitude else {
            return
        }
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func call(_ place: HasPhoneNumber) {
        guard let phoneNumber = place.phoneNumber, let url = URL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
