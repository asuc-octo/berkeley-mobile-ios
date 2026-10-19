//
//  GymOccupancyView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct GymOccupancyView: View {
    @InjectedObservable(\.gymOccupancyViewModel) var viewModel

    let location: GymOccupancyLocation

    var body: some View {
        VStack {
            let gymName = location.rawValue
            if let occupancy = viewModel.occupancyPercentages[location] {
                GymOccupancyGaugeView(occupancy: occupancy, gymName: gymName)
            } else {
                GymRedactedOccupancyGaugeView(gymName: gymName)
            }
            
            Text(location.rawValue)
                .font(Font(BMFont.regular(9)))
        }
        .onAppear {
            if viewModel.occupancyPercentages[location] == nil {
                viewModel.startAutoRefresh()
            }
        }
    }
}


// MARK: - GymOccupancyGaugeView

struct GymOccupancyGaugeView: View {
    var occupancy: Double
    var gymName: String
    
    var body: some View {
        Gauge(value: occupancy, in: GymOccupancyViewModel.Constants.minOccupancy...GymOccupancyViewModel.Constants.maxOccupancy) {
            Text(gymName)
        } currentValueLabel: {
            Text("\(Int(occupancy))")
        } minimumValueLabel: {
            Text("\(Int(GymOccupancyViewModel.Constants.minOccupancy))")
                .foregroundStyle(.green)
        } maximumValueLabel: {
            Text("\(Int(GymOccupancyViewModel.Constants.maxOccupancy))")
                .foregroundStyle(.red)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(GymOccupancyViewModel.getOccupancyColor(percentage: occupancy))
    }
}


// MARK: - GymRedactedOccupancyGaugeView

struct GymRedactedOccupancyGaugeView: View {
    var gymName: String
    
    var body: some View {
        GymOccupancyGaugeView(occupancy: 0, gymName: gymName)
            .redacted(reason: .placeholder)
            .overlay(
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 25, height: 25)
                    .overlay(
                        ProgressView()
                            .controlSize(.mini)
                    )
            )
    }
}

#Preview {
    Group {
        GymOccupancyGaugeView(occupancy: 78, gymName: "RSF Weight Rooms")
        GymRedactedOccupancyGaugeView(gymName: "CMS Fitness Center")
    }
}
