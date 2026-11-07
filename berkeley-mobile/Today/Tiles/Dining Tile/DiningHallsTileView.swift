//
//  DiningHallsTileView.swift
//  berkeley-mobile
//
//  Created by Noel Sason on 11/7/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import CoreLocation
import FactoryKit
import SwiftUI

struct DiningHallsTileView: View {
    @InjectedObservable(\.diningHallsViewModel) private var viewModel

    // Local copies of BMLocationManager state so SwiftUI re-renders on `.locationUpdated`.
    // Distances still come from `distanceToUser`, which reads the same singleton value.
    @State private var userLocation = BMLocationManager.shared.userLocation
    @State private var authorizationStatus = BMLocationManager.shared.authorizationStatus
    @State private var selectedDiningHall: BMDiningHall?

    private static let maxDisplayedHalls = 3

    // One formatter per precision: MeasurementFormatter does not reliably pick up changes to
    // `numberFormatter` after its first use, so a shared formatter shows "0 mi" for short distances.
    private static let feetFormatter = makeDistanceFormatter(maximumFractionDigits: 0)
    private static let milesFormatter = makeDistanceFormatter(maximumFractionDigits: 1)

    private static func makeDistanceFormatter(maximumFractionDigits: Int) -> MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }

    private static let openingTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    var body: some View {
        Group {
            if viewModel.isFetching {
                progressView
            } else if viewModel.diningHalls.isEmpty {
                noDiningHallsView
            } else if authorizationStatus == .denied || authorizationStatus == .notDetermined {
                Button {
                    BMLocationManager.shared.handleLocationAuthorization()
                } label: {
                    locationPromptView
                }
                .buttonStyle(.plain)
            } else if authorizationStatus == .restricted {
                locationPromptView
            } else if userLocation == nil {
                progressView
            } else {
                // Re-evaluate every minute so "Now: Lunch" and "Opens 5:00 PM" stay current between
                // the open/closed timer updates in DiningHallsViewModel.
                TimelineView(.everyMinute) { context in
                    let halls = nearestDiningHalls(at: context.date)
                    if halls.isEmpty {
                        noDiningHallsView
                    } else {
                        tileContent(for: halls)
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(BMLocationManager.notificationCenter.publisher(for: .locationUpdated)) { _ in
            userLocation = BMLocationManager.shared.userLocation
            authorizationStatus = BMLocationManager.shared.authorizationStatus
        }
        .sheet(item: $selectedDiningHall) { diningHall in
            NavigationStack {
                DiningDetailView(diningHall: diningHall, initialMealType: diningHall.currentMealType(at: Date()))
            }
            .presentationDragIndicator(.visible)
        }
    }

    /// The nearest dining halls, open ones first, each group sorted by distance.
    private func nearestDiningHalls(at date: Date) -> [DiningHallStatus] {
        let halls = viewModel.diningHalls.compactMap { diningHall -> DiningHallStatus? in
            guard let distance = diningHall.distanceToUser else {
                return nil
            }
            return DiningHallStatus(diningHall: diningHall, distance: distance, date: date)
        }

        return halls
            .sorted {
                if $0.isOpen != $1.isOpen {
                    return $0.isOpen
                }
                return $0.distance < $1.distance
            }
            .prefix(Self.maxDisplayedHalls)
            .map { $0 }
    }

    private func tileContent(for halls: [DiningHallStatus]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dining Halls")
                    .font(Font(BMFont.bold(15)))
                Spacer()
                Image(systemName: "fork.knife")
                    .font(.footnote)
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(halls, id: \.diningHall.id) { hallStatus in
                    Button {
                        selectedDiningHall = hallStatus.diningHall
                    } label: {
                        diningHallRow(for: hallStatus)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
    }

    private func diningHallRow(for hallStatus: DiningHallStatus) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(hallStatus.diningHall.name)
                .font(Font(BMFont.medium(13)))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: 6) {
                Circle()
                    .fill(hallStatus.isOpen ? Color.green : Color.red)
                    .frame(width: 6, height: 6)
                Text(statusText(for: hallStatus))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                Text(formatDistance(hallStatus.distance))
                    .opacity(0.8)
            }
            .font(Font(BMFont.regular(11)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func statusText(for hallStatus: DiningHallStatus) -> String {
        if hallStatus.isOpen {
            if let mealType = hallStatus.currentMealType {
                return "Now: \(mealType.rawValue)"
            }
            return "Open"
        }

        if let nextOpening = hallStatus.nextOpening {
            return "Opens \(Self.openingTimeFormatter.string(from: nextOpening))"
        }
        return "Closed"
    }

    private func formatDistance(_ miles: Double) -> String {
        // Show feet for short distances, miles otherwise
        if miles < 0.1 {
            let feet = Measurement(value: miles * 5280, unit: UnitLength.feet)
            return Self.feetFormatter.string(from: feet)
        } else {
            let measurement = Measurement(value: miles, unit: UnitLength.miles)
            return Self.milesFormatter.string(from: measurement)
        }
    }

    private var locationPromptView: some View {
        VStack(spacing: 6) {
            Image(systemName: "location.slash")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.7))
            Text("Turn on location to see nearby dining halls")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private var noDiningHallsView: some View {
        VStack(spacing: 6) {
            Image(systemName: "fork.knife")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.7))
            Text("No dining halls available")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var progressView: some View {
        ProgressView()
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - Supporting Types

private struct DiningHallStatus {
    let diningHall: BMDiningHall
    /// Distance to the user in miles.
    let distance: Double
    let isOpen: Bool
    let currentMealType: BMMeal.BMMealType?
    let nextOpening: Date?

    init(diningHall: BMDiningHall, distance: Double, date: Date) {
        self.diningHall = diningHall
        self.distance = distance
        // Computed from `hours` instead of `diningHall.isOpen` so the status matches `date`.
        let hours = diningHall.hours
        isOpen = hours.contains { $0.contains(date) }
        currentMealType = isOpen ? diningHall.currentMealType(at: date) : nil
        nextOpening = hours.map(\.start).filter { $0 > date }.min()
    }
}

private extension BMDiningHall {
    /// The regular meal being served at `date`, if its serving time can be parsed.
    func currentMealType(at date: Date) -> BMMeal.BMMealType? {
        return BMMeal.BMMealType.regularMealTypes.first { mealType in
            guard let interval = meals[mealType]?.time?.convertToDateInterval(on: date) else {
                return false
            }
            return interval.contains(date)
        }
    }
}

#Preview {
    DiningHallsTileView()
        .frame(width: 180, height: 180)
        .background(Color(red: 0.10, green: 0.29, blue: 0.32))
}
