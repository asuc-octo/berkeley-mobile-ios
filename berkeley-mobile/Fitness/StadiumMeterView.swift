//
//  StadiumMeterView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 12/8/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct StadiumMeterView: View {
    @StateObject private var viewModel = StadiumMeterViewModel()
    
    
    
    private struct Constants {
        static let minOccupancy: CGFloat = 0
        static let maxOccupancy: CGFloat = 100
        static let occupancyText = "Stadium Fitness Center"
        static let labelSize: CGFloat = 9
        
        static let mediumLowerBound: CGFloat = 70
        static let mediumHighBound: CGFloat = 90
        static let highHighBound: CGFloat = 200
        
        static var currTimes : String {
            let currDate = Date()
            
            let currDay =
            String(currDate.formatted(Date.FormatStyle().weekday(.wide)))
            
            switch currDay {
            case "Saturday":
                return currDay + ": 8 a.m. - 6 p.m."
            case "Sunday":
                return currDay + ": 8 a.m - 11 p.m."
            default :
                return currDay + ": 7 a.m. - 11 p.m."
    
            }
        }
        
        
    }
    
    var body: some View {
        
        VStack {
            if let occupancy = viewModel.occupancy {
                Gauge(value: occupancy, in: Constants.minOccupancy...Constants.maxOccupancy) {
                    Text(Constants.occupancyText)
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
                .tint(colorGauge(occupancy))
                
                Text(Constants.occupancyText)
                    .font(Font(BMFont.regular(Constants.labelSize)))
            } else {
                let occupancy = 0
                Gauge(value: CGFloat(occupancy), in: Constants.minOccupancy...Constants.maxOccupancy) {
                    Text(Constants.occupancyText)
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
                .tint(colorGauge(Double(occupancy)))
                .redacted(reason: .placeholder)
                
                Text(Constants.occupancyText)
                    .font(Font(BMFont.regular(Constants.labelSize)))
            }
            Text(Constants.currTimes)
        }
        .background(Color(uiColor: BMColor.cardBackground))
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel
                .stopAutoRefresh()
        }
        
        
    }
    
    private func colorGauge(_ value: Double) -> Color {
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


// MARK: - RSFViewModel

class StadiumMeterViewModel: NSObject, ObservableObject {
    
    @Published var occupancy: Double? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let scrapper = StadiumScrapper()
    private var timer: Timer?

    override init() {
        super.init()
        scrapper.delegate = self
    }

    func startAutoRefresh() {
        refreshOccupancy()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true)  { [weak self] _ in
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
        scrapper.scrape(at: StadiumScrapper.Constants.stadiumURLString)
    }

}


// MARK: - RSFScrapperDelegate

extension StadiumMeterViewModel: StadiumScrapperDelegate {
    
    func stadiumScrapperDidFinishScrapping(result: String?) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let result = result, let occupancy = result.split(separator: "%").first {
                self.occupancy = Double(String(occupancy))
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to parse occupancy data."
            }
        }
    }

    func stadiumScrapperDidError(with errorDescription: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = errorDescription
        }
    }
    
}

#Preview {
    StadiumMeterView()
}
