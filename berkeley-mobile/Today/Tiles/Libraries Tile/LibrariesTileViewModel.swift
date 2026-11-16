//
//  LibrariesTileViewModel.swift
//  berkeley-mobile
//
//  Created by Lewis Yang on 4/27/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import Observation

struct LibraryDistance {
    let library: BMLibrary
    /// Distance to the user in miles.
    let distance: Double
}

@MainActor
@Observable
class LibrariesTileViewModel {
    private(set) var isFetching = false
    private(set) var libraries: [BMLibrary] = []

    // Local copies of BMLocationManager state so observers re-render on `.locationUpdated`.
    // Distances still come from `distanceToUser`, which reads the same singleton value.
    private(set) var userLocation = BMLocationManager.shared.userLocation
    private(set) var authorizationStatus = BMLocationManager.shared.authorizationStatus

    @ObservationIgnored
    private let maxNearestLibrariesCount = 3
    @ObservationIgnored
    private var locationUpdatedCancellable: AnyCancellable?

    var isLocationAuthorizationRequestable: Bool {
        authorizationStatus == .denied || authorizationStatus == .notDetermined
    }

    var isLocationRestricted: Bool {
        authorizationStatus == .restricted
    }

    /// The libraries closest to the user, nearest first.
    var nearestLibraries: [LibraryDistance] {
        guard userLocation != nil else {
            return []
        }

        return libraries
            .compactMap { library in
                guard let distance = library.distanceToUser else {
                    return nil
                }
                return LibraryDistance(library: library, distance: distance)
            }
            .sorted { $0.distance < $1.distance }
            .prefix(maxNearestLibrariesCount)
            .map { $0 }
    }

    init() {
        locationUpdatedCancellable = BMLocationManager.notificationCenter
            .publisher(for: .locationUpdated)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateLocationState()
                }
            }
        fetchLibraries()
    }

    func requestLocationAuthorization() {
        BMLocationManager.shared.handleLocationAuthorization()
    }

    private func fetchLibraries() {
        isFetching = true
        DataManager.shared.fetch(source: LibraryDataSource.self) { [weak self] libraries in
            guard let self else {
                return
            }
            self.libraries = libraries as? [BMLibrary] ?? []
            self.isFetching = false
        }
    }

    private func updateLocationState() {
        userLocation = BMLocationManager.shared.userLocation
        authorizationStatus = BMLocationManager.shared.authorizationStatus
    }
}
