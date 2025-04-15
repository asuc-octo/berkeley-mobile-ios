//
//  GymOccupancyViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

typealias GymOccupancyLocation = GymOccupancyViewModel.GymOccupancyLocation

class GymOccupancyViewModel: NSObject, ObservableObject {
    
    enum GymOccupancyLocation: String {
        case rsf = "RSF Weight Rooms"
        case stadium = "CMS Fitness Center"
        
        func getURLString() -> String {
            self == .rsf ? Constants.rsfURLString : Constants.stadiumURLString
        }
    }
    
    struct Constants {
        static let rsfURLString = "https://safe.density.io/#/displays/dsp_956223069054042646?token=shr_o69HxjQ0BYrY2FPD9HxdirhJYcFDCeRolEd744Uj88e&share&qr"
        static let stadiumURLString = "https://safe.density.io/#/displays/dsp_1160333760881754703?token=shr_CPp9qbE0jN351cCEQmtDr4R90r3SIjZASSY8GU5O3gR&share&qr"
        static let refreshIntervalSecs = 30.0
        
        static let minOccupancy: CGFloat = 0
        static let maxOccupancy: CGFloat = 100
        
        static let mediumLowerBound: CGFloat = 70
        static let mediumHighBound: CGFloat = 90
        static let highHighBound: CGFloat = 200
    }
    
    @Published var occupancyPercentage: Double? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var location: GymOccupancyLocation
    
    private var completionHandler: ((Double?) -> Void)?
    
    private let scrapper = GymOccupancyScrapper()
    private var timer: Timer?
    
    init(location: GymOccupancyLocation) {
        self.location = location
        super.init()
        scrapper.delegate = self
    }

    func startAutoRefresh() {
        refreshOccupancy()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.refreshIntervalSecs, repeats: true)  { [weak self] _ in
            self?.refreshOccupancy()
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    private func refreshOccupancy() {
        isLoading = true
        errorMessage = nil
        scrapper.scrape(at: location.getURLString())
    }
    
    /// An alternative to get updated occupancy percentage from `GymOccupancyScrapperDelegate` via a completion handler
    func refreshWithCompletionHandler(completionHandler: @escaping ((Double?) -> Void)) {
        refreshOccupancy()
        self.completionHandler = completionHandler
    }
    
    static func getOccupancyColor(percentage: Double) -> Color {
        switch percentage {
        case Constants.mediumLowerBound..<Constants.mediumHighBound:
            return .orange
        case Constants.mediumHighBound...Constants.highHighBound:
            return .red
        default:
            return .green
        }
    }
    
}


// MARK: - GymOccupancyScrapperDelegate

extension GymOccupancyViewModel: GymOccupancyScrapperDelegate {
    
    func scrapperDidFinishScrapping(result: String?) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let result, let occupancy = result.split(separator: "%").first {
                self.occupancyPercentage = Double(String(occupancy))
                self.completionHandler?(Double(String(occupancy)))
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to parse occupancy data."
            }
        }
    }

    func scrapperDidError(with errorDescription: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = errorDescription
        }
    }
    
}
