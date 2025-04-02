//
//  CLLocation+Extension.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/23/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import MapKit

extension CLLocation {
    
    /// Returns the distance to the user in miles if user location is shared, otherwise `nil`.
    func distanceFromUser() -> Double? {
        guard let userLocation = BMLocationManager.shared.userLocation else {
            return nil
        }
        
        let metersDistance = userLocation.distance(from: self)
        let measurement = Measurement(value: metersDistance, unit: UnitLength.meters)
        
        return measurement.converted(to: .miles).value
    }
}
