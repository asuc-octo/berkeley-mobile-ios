//
//  LocationManager.swift
//  bm-persona
//
//  Created by Kevin Hu on 4/17/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Location Manager Notifications

extension Notification.Name {
    /// Notification sent whenever the user's location is fetched or changes.
    static var locationUpdated: Notification.Name {
        return .init(rawValue: "LocationManager.locationUpdated")
    }
}

// MARK: - Location Manager

/// Wrapper for `CLLocationManager`. Intended to work as a singleton location manager.
/// Sends updated to observers using `NotificationCenter`.
class LocationManager: NSObject {

    /// Singleton instance of a `LocationManager`.
    static let shared = LocationManager()

    /// The notification center used to send location updates.
    static var notificationCenter = NotificationCenter.default
    private var _locationManager: CLLocationManager!

    /// The most-updated location for the current user. `nil` if no location data has ever been recieved.
    open var userLocation: CLLocation?

    override init() {
        super.init()

        _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.requestWhenInUseAuthorization()
        userLocation = _locationManager.location
    }

    deinit {
        _locationManager.stopUpdatingLocation()
    }

    /// Starts collecting the user's location.
    func requestLocation() {
        _locationManager.startUpdatingLocation()
    }
}

// MARK: CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            LocationManager.notificationCenter.post(name: .locationUpdated, object: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            if clErr.code == CLError.denied {
                manager.stopUpdatingLocation()
            }
        }
        print("Location Error: ", error)
    }
}
