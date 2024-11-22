//
//  SafetyViewManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import CoreLocation
import Firebase
import MapKit
import SwiftUI


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


// MARK: - SafetyViewManager

final class SafetyViewManager: NSObject, ObservableObject {
    
    private struct Constants {
        static let safetyLogsCollectionName = "Safety Logs"
    }
    
    @Published var region = MKCoordinateRegion(
        center: CLLocation(latitude: CLLocationDegrees(exactly: 37.871684)!, longitude: CLLocationDegrees(-122.259934)).coordinate,
        span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var safetyLogs = [BMSafetyLog]()
    @Published var filteredSafetyLogs = [BMSafetyLog]()
    @Published var selectedSafetyLogFilterStates: [BMSafetyLogFilterState] = [] {
        didSet {
            updateFilterState()
        }
    }
    @Published var isFetchingLogs = false
    
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setup()
        fetchResourceCategories()
        listenForSafetyLogs()
    }
    
    private func setup() {
        switch locationManager.authorizationStatus {
        // If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        // If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    private func fetchResourceCategories() {
        isFetchingLogs = true
        
        db.collection(Constants.safetyLogsCollectionName).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                DispatchQueue.main.async {
                    self.isFetchingLogs = false
                }
                return
            }
            
            let fetchedSafetyLogs = self.convertSafetyLogsDocsIntoSafetyLogs(for: documents)
            
            DispatchQueue.main.async {
                self.safetyLogs = fetchedSafetyLogs
                self.filteredSafetyLogs = fetchedSafetyLogs
                self.isFetchingLogs = false
            }
        }
    }
    
    private func listenForSafetyLogs() {
        db.collection(Constants.safetyLogsCollectionName).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            let newSafetyLogs = self.convertSafetyLogsDocsIntoSafetyLogs(for: documents)
            
            DispatchQueue.main.async { 
                self.filteredSafetyLogs = self.filteredSafetyLogs == self.safetyLogs ? newSafetyLogs : self.filteredSafetyLogs
                self.safetyLogs = newSafetyLogs
                self.updateFilterState()
            }
        }
    }
    
    private func convertSafetyLogsDocsIntoSafetyLogs(for docs: [QueryDocumentSnapshot]) -> [BMSafetyLog] {
        var safetyLogs = docs.compactMap { try? $0.data(as: BMSafetyLog.self) }
        safetyLogs.sort(by: { $0.date > $1.date })
        return safetyLogs
    }
    
    private func updateFilterState() {
        guard !selectedSafetyLogFilterStates.isEmpty else {
            filteredSafetyLogs = safetyLogs
            return
        }
        
        var newFilteredSafetyLogs = [BMSafetyLog]()
        
        let currentDate = Date()
        let timeFilterStates = selectedSafetyLogFilterStates.filter { BMSafetyLogFilterState.timeFilterStates.contains($0) }
        let crimeTypeFilterStates = Array(Set(selectedSafetyLogFilterStates).subtracting(Set(timeFilterStates)))
        
        if !timeFilterStates.isEmpty {
            for selectedTimeFilterState in timeFilterStates {
                switch selectedTimeFilterState {
                case .thisMonth:
                    let thisMonthLogs = safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .month)}
                    newFilteredSafetyLogs.append(contentsOf: thisMonthLogs)
                case .thisWeek:
                    let thisWeekLogs = safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .weekOfYear)}
                    newFilteredSafetyLogs.append(contentsOf: thisWeekLogs)
                case .thisYear:
                    let thisYearLogs = safetyLogs.filter{Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .year)}
                    newFilteredSafetyLogs.append(contentsOf: thisYearLogs)
                case .today:
                    let todayLogs = safetyLogs.filter{Calendar.current.isDateInToday($0.date)}
                    newFilteredSafetyLogs.append(contentsOf: todayLogs)
                default:
                    break
                }
            }
        } else {
            newFilteredSafetyLogs = safetyLogs
        }
        
        for crimeFilterState in crimeTypeFilterStates {
            newFilteredSafetyLogs = newFilteredSafetyLogs.filter { $0.getSafetyLogState == crimeFilterState }
        }
        
        withAnimation {
            filteredSafetyLogs = newFilteredSafetyLogs
        }
    }
    
}


// MARK: - CLLocationManagerDelegate

extension SafetyViewManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else {
            return
        }
        
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


// MARK: - Sample Data

extension SafetyViewManager {
    
    static func getSampleSafetyLog() -> BMSafetyLog {
        BMSafetyLog(crime: "Aggravated Assault", date: Date(), detail: "On 4/10/24 at approximately 1855 hours, victim was walking north bound on Gayley Road. A blue convertible Pontiac driving south bound Gayley road from Hearst Ave struck the victim with an unknown projectile. The suspect vehicle continued south bound Gayley Road then proceeded east bound Rim Way. The vehicle was occupied by 2 males and 1 female. The rear passenger subject was responsible for the incident.   Case 24-01042  Aggravated assault is an unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault is usually accompanied by the use of a weapon or by means likely to produce death or great bodily harm.", latitude: 1.0, location: "Gayley Road, South of Hearst Ave", longitude: 1.0)
    }
    
}
