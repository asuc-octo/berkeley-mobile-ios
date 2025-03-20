//
//  BMLocationManager.swift
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
        return .init(rawValue: "BMLocationManager.locationUpdated")
    }
}


// MARK: - BMLocation Manager

/// Wrapper for `CLLocationManager`. Intended to work as a singleton location manager.
/// Sends updated to observers using `NotificationCenter`.
class BMLocationManager: NSObject {
    /// Singleton instance of a `BMLocationManager`.
    static let shared = BMLocationManager()

    /// The notification center used to send location updates.
    static var notificationCenter = NotificationCenter.default
    private var locationManager: CLLocationManager!

    /// The most-updated location for the current user. `nil` if no location data has ever been recieved.
    open var userLocation: CLLocation?

    override init() {
        super.init()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        userLocation = locationManager.location
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }

    /// Starts collecting the user's location.
    func requestLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func handleLocationAuthorization(fromDelegate: Bool = false) {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            guard !fromDelegate,
                  let url = URL(string: UIApplication.openSettingsURLString) else {
                break
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            break
        }
        
        if authStatus != .authorizedWhenInUse {
            userLocation = nil
            BMLocationManager.notificationCenter.post(name: .locationUpdated, object: nil)
        }
    }
}


// MARK: CLLocationManagerDelegate

extension BMLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationAuthorization(fromDelegate: true)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            BMLocationManager.notificationCenter.post(name: .locationUpdated, object: location)
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
