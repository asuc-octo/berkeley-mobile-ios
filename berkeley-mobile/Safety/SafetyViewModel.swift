//
//  SafetyViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

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

final class SafetyViewModel: NSObject, ObservableObject {
    struct BMCrimeInfo {
        var color: Color
        var count: Int
    }
    
    @Published var region = BMConstants.berkeleyRegion
    @Published var safetyLogs = [BMSafetyLog]()
    @Published var filteredSafetyLogs = [BMSafetyLog]()
    @Published var crimeInfos = [BMSafetyLogFilterState: BMCrimeInfo]()
    @Published var isLoading = false
    @Published var alert: BMAlert?
    @Published var selectedSafetyLogFilterStates: [BMSafetyLogFilterState] = [] {
        didSet {
            updateFilterState()
        }
    }
    
    override init() {
        super.init()
        
        isLoading = true
        Task {
            await listenForSafetyLogs()
        }
    }
    
    @MainActor
    private func listenForSafetyLogs() async {
        do {
            defer {
                isLoading = false
            }
            let fetchedSafetyLogs = try await BMNetworkingManager.shared.fetchSafetyLogs()
            safetyLogs = fetchedSafetyLogs
            filteredSafetyLogs = filteredSafetyLogs == safetyLogs ? fetchedSafetyLogs : filteredSafetyLogs
            updateFilterState()
            associateCrimesWithColor()
        } catch {
            withoutAnimation {
                self.alert = BMAlert(title: "Failed To Fetch Safety Logs", message: error.localizedDescription, type: .notice)
            }
        }
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
        
        filteredSafetyLogs = newFilteredSafetyLogs
    }
    
    private func associateCrimesWithColor() {
        let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange, .mint]
        let displayCrimeTypes: [BMSafetyLogFilterState] = [.aggravatedAssault, .burglary, .robbery, .sexualAssault, .others]
        for (crime, color) in zip(displayCrimeTypes, colors) {
            let crimeTypeCount = safetyLogs.filter { $0.getSafetyLogState == crime }.count
            crimeInfos[crime] = BMCrimeInfo(color: color, count: crimeTypeCount)
        }
    }
}


// MARK: - Sample Data

extension SafetyViewModel {
    static func getSampleSafetyLog() -> BMSafetyLog {
        BMSafetyLog(crime: "Aggravated Assault", date: Date(), detail: "On 4/10/24 at approximately 1855 hours, victim was walking north bound on Gayley Road. A blue convertible Pontiac driving south bound Gayley road from Hearst Ave struck the victim with an unknown projectile. The suspect vehicle continued south bound Gayley Road then proceeded east bound Rim Way. The vehicle was occupied by 2 males and 1 female. The rear passenger subject was responsible for the incident.   Case 24-01042  Aggravated assault is an unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault is usually accompanied by the use of a weapon or by means likely to produce death or great bodily harm.", latitude: 37.87015100000001, location: "Gayley Road, South of Hearst Ave", longitude: -122.2594606)
    }
}
