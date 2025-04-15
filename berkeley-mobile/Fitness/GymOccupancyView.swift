//
//  GymOccupancyView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GymOccupancyView: View {
    @EnvironmentObject var viewModel: GymOccupancyViewModel
    
    var body: some View {
        VStack {
            if let occupancy = viewModel.occupancyPercentage {
                GymOccupancyGaugeView(occupancy: occupancy, gymName: viewModel.location.rawValue)
            } else {
                GymRedactedOccupancyGaugeView(gymLocationName: viewModel.location.rawValue)
            }
            
            Text(viewModel.location.rawValue)
                .font(Font(BMFont.regular(9)))
        }
        .onAppear {
            if viewModel.occupancyPercentage == nil {
                viewModel.startAutoRefresh()
            }
        }
    }
}


// MARK: - GymOccupancyGaugeView

struct GymOccupancyGaugeView: View {
    @EnvironmentObject var viewModel: GymOccupancyViewModel
    
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
    var gymLocationName: String
    
    var body: some View {
        GymOccupancyGaugeView(occupancy: 0, gymName: gymLocationName)
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
            .environmentObject(GymOccupancyViewModel(location: .rsf))
        GymRedactedOccupancyGaugeView(gymLocationName: "CMS Fitness Center")
            .environmentObject(GymOccupancyViewModel(location: .stadium))
    }
}
