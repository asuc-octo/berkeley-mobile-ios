//
//  SafetyViewManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import CoreLocation
import MapKit
import SwiftUI
import Firebase

struct BMSafetyLog: Identifiable, Codable, Hashable {
    var id = UUID()
    var crime: String
    var date: Date
    var detail: String
    var latitude: Double
    var location: String
    var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case crime
        case date = "date_time"
        case detail
        case latitude
        case location
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var getSafetyLogState: BMSafetyLogFilterState {
        for filterState in BMSafetyLogFilterState.allCases {
            if filterState.rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == crime.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                return filterState
            }
        }
        return .others
    }
}

enum BMSafetyLogFilterState: String, CaseIterable {
    case today = "Today", thisWeek = "This Week", thisMonth = "This Month", thisYear = "This Year"
    case robbery = "Robbery", aggravatedAssault = "Aggravated Assault", burglary = "Burglary", sexualAssault = "Sexual Assault", others = "Others"
    static var timeFilterStates: [BMSafetyLogFilterState] = [.today, .thisWeek, .thisMonth, .thisYear]
}

extension BMSafetyLogFilterState: Identifiable {
    var id: Self { self }
}

//MARK: - SafetyViewManager
final class SafetyViewManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934)).coordinate,
        span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var safetyLogs = [BMSafetyLog]()
    @Published var filteredSafetyLogs = [BMSafetyLog]()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
        fetchResourceCategories()
    }
    
    private func setup() {
        switch locationManager.authorizationStatus {
        //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        //If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    private func fetchResourceCategories() {
        let db = Firestore.firestore()
        db.collection("Safety Logs").getDocuments { querySnapshot, error in
            guard error == nil else { return }
            guard let documents = querySnapshot?.documents else { return }
            var fetchedSafetyLogs = [BMSafetyLog]()
            fetchedSafetyLogs = documents.compactMap { queryDocumentSnapshot -> BMSafetyLog? in
                return try? queryDocumentSnapshot.data(as: BMSafetyLog.self)
            }
            fetchedSafetyLogs.sort(by: { $0.date > $1.date })
            self.safetyLogs = fetchedSafetyLogs
            self.filteredSafetyLogs = fetchedSafetyLogs
        }
    }
}

extension SafetyViewManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locations.last.map {
            region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}
