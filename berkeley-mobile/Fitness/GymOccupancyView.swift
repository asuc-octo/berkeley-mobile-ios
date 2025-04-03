//
//  GymOccupancyView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GymOccupancyView: View {
    @ObservedObject var viewModel: GymOccupancyViewModel
    
    private struct Constants {
        static let minOccupancy: CGFloat = 0
        static let maxOccupancy: CGFloat = 100
        static let labelSize: CGFloat = 9
        
        static let mediumLowerBound: CGFloat = 70
        static let mediumHighBound: CGFloat = 90
        static let highHighBound: CGFloat = 200
    }
    
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
    var occupancy: Double
    var gymName: String
    
    private struct Constants {
        static let minOccupancy: CGFloat = 0
        static let maxOccupancy: CGFloat = 100
        
        static let mediumLowerBound: CGFloat = 70
        static let mediumHighBound: CGFloat = 90
        static let highHighBound: CGFloat = 200
    }
    
    var body: some View {
        Gauge(value: occupancy, in: Constants.minOccupancy...Constants.maxOccupancy) {
            Text(gymName)
        } currentValueLabel: {
            Text("\(Int(occupancy))")
        } minimumValueLabel: {
            Text("\(Int(Constants.minOccupancy))")
                .foregroundStyle(.green)
        } maximumValueLabel: {
            Text("\(Int(Constants.maxOccupancy))")
                .foregroundStyle(.red)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(getGaugeColor(occupancy))
    }
    
    private func getGaugeColor(_ value: Double) -> Color {
        switch value {
        case Constants.mediumLowerBound...Constants.mediumHighBound:
            .orange
        case Constants.mediumHighBound...Constants.highHighBound:
            .red
        default:
            .green
        }
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
        GymRedactedOccupancyGaugeView(gymLocationName: "CMS Fitness Center")
    }
}
