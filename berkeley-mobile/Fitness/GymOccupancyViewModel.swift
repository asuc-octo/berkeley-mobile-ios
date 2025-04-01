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
    
    private struct Constants {
        static let rsfURLString = "https://safe.density.io/#/displays/dsp_956223069054042646?token=shr_o69HxjQ0BYrY2FPD9HxdirhJYcFDCeRolEd744Uj88e&share&qr"
        static let stadiumURLString = "https://safe.density.io/#/displays/dsp_1160333760881754703?token=shr_CPp9qbE0jN351cCEQmtDr4R90r3SIjZASSY8GU5O3gR&share&qr"
        static let refreshIntervalSecs = 30.0
    }
    
    @Published var occupancyPercentage: Double? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var location: GymOccupancyLocation

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

    func refreshOccupancy() {
        isLoading = true
        errorMessage = nil
        scrapper.scrape(at: location.getURLString())
    }

}


// MARK: - GymOccupancyScrapperDelegate

extension GymOccupancyViewModel: GymOccupancyScrapperDelegate {
    
    func rsfScrapperDidFinishScrapping(result: String?) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let result = result, let occupancy = result.split(separator: "%").first {
                self.occupancyPercentage = Double(String(occupancy))
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to parse occupancy data."
            }
        }
    }

    func rsfScrapperDidError(with errorDescription: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = errorDescription
        }
    }
    
}
