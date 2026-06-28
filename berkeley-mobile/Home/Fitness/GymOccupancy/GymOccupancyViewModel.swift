//
//  GymOccupancyViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import FirebaseFirestore
import SwiftUI

typealias GymOccupancyLocation = GymOccupancyViewModel.GymOccupancyLocation

struct GymOccupancyLocationData: Codable, Identifiable, Hashable {
    var id: String
    var gymName: String
    var occupancyPercentage: Int
    var sourcePageURL: URL
    var scrapedTimestamp: Date

    enum CodingKeys: String, CodingKey {
        case id = "gymId"
        case gymName
        case occupancyPercentage
        case sourcePageURL = "sourcePageUrl"
        case scrapedTimestamp = "scrapedAt"
    }
}

@Observable
class GymOccupancyViewModel: NSObject {
    
    enum GymOccupancyLocation: String, CaseIterable {
        case rsf = "RSF Weight Rooms"
        case stadium = "CMS Fitness Center"

        var documentName: String {
            return switch self {
            case .rsf: Constants.rsfWeightRoomDocName
            case .stadium: Constants.csmFitnessCenterDocName
            }
        }
    }
    
    struct Constants {
        static let refreshIntervalSecs: TimeInterval = 15 * 60

        static let gymOccupancyCollectionName = "Gym Occupancy Meters"
        static let csmFitnessCenterDocName = "cms-fitness"
        static let rsfWeightRoomDocName = "rsf-weight-room"

        static let minOccupancy: CGFloat = 0
        static let maxOccupancy: CGFloat = 100
        
        static let mediumLowerBound: CGFloat = 70
        static let mediumHighBound: CGFloat = 90
        static let highHighBound: CGFloat = 200
    }

    var occupancyPercentages: [GymOccupancyLocation: Double] = [:]
    var isLoading = false
    var errorMessage: String? = nil

    @ObservationIgnored
    private var completionHandler: (([GymOccupancyLocation: Double]) -> Void)?
    @ObservationIgnored
    private var timer: Timer?

    func startAutoRefresh() {
        refreshOccupancy()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.refreshIntervalSecs, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.refreshOccupancy()
            }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    private func refreshOccupancy() {
        isLoading = true
        errorMessage = nil

        Task {
            let results = await fetchOccupancyPercentages()

            completionHandler?(results)
            self.occupancyPercentages = results
            isLoading = false
        }
    }

    func fetchOccupancyPercentages() async -> [GymOccupancyLocation: Double] {
        let db = Firestore.firestore()

        return await withTaskGroup(of: (location: GymOccupancyLocation, percentage: Double).self, returning: [GymOccupancyLocation: Double].self) { taskGroup in
            for gymLocation in GymOccupancyLocation.allCases {
                taskGroup.addTask {
                    let docRef = db.collection(Constants.gymOccupancyCollectionName).document(gymLocation.documentName)
                    do {
                        let data: GymOccupancyLocationData = try await docRef.getDocument(as: GymOccupancyLocationData.self)
                        return (gymLocation, Double(data.occupancyPercentage))
                    } catch {
                        return (gymLocation, 0.0)
                    }
                }
            }

            return await taskGroup.reduce(into: [GymOccupancyLocation: Double]()) { result, item in
                result[item.location] = item.percentage
            }
        }
    }
    
    /// An alternative to get updated occupancy percentage from `GymOccupancyScrapperDelegate` via a completion handler
    func refreshWithCompletionHandler(completionHandler: @escaping (([GymOccupancyLocation: Double]) -> Void)) {
        self.completionHandler = completionHandler
        refreshOccupancy()
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
