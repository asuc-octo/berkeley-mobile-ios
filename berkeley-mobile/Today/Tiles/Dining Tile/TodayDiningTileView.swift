//
//  TodayDiningTileView.swift
//  berkeley-mobile
//
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI
import UIKit

struct TodayDiningTileView: View {
    @InjectedObservable(\.diningHallsViewModel) private var viewModel
    @InjectedObject(\.homeViewModel) private var homeViewModel

    private static let nearestCount = 3

    private var nearestHalls: [BMDiningHall] {
        Array(
            viewModel.diningHalls
                .sorted { ($0.distanceToUser ?? .infinity) < ($1.distanceToUser ?? .infinity) }
                .prefix(Self.nearestCount)
        )
    }

    private var shouldRedact: Bool {
        viewModel.diningHalls.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            VStack(alignment: .leading, spacing: 6) {
                if shouldRedact {
                    ForEach(0..<Self.nearestCount, id: \.self) { _ in
                        placeholderRow
                    }
                } else {
                    ForEach(nearestHalls, id: \.docID) { hall in
                        diningRow(for: hall)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .redacted(reason: shouldRedact ? .placeholder : [])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { navigateToDiningInHome() }
    }

    private var header: some View {
        HStack {
            Text("Dining")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "fork.knife")
                .font(.callout)
        }
    }

    @ViewBuilder
    private func diningRow(for hall: BMDiningHall) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(hall.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            HStack(spacing: 6) {
                OpenClosedStatusView(status: hall.isOpen ? .open : .closed)
                Text("\(hall.distanceToUser ?? 0.0, specifier: "%.1f") mi")
                    .font(Font(BMFont.light(10)))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var placeholderRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Dining Hall")
                .font(.caption)
                .fontWeight(.semibold)
            HStack(spacing: 6) {
                OpenClosedStatusView(status: .open)
                Text("0.0 mi")
                    .font(Font(BMFont.light(10)))
            }
        }
    }

    private func navigateToDiningInHome() {
        homeViewModel.showDining()

        let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate
        let tabBarController = sceneDelegate?.window?.rootViewController as? TabBarController
        tabBarController?.selectedIndex = 1
    }
}
