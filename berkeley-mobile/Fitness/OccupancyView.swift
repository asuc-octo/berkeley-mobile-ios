//
//  OccupancyView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 12/3/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct OccupancyView: View {
    @StateObject private var viewModel = OccupancyViewModel()
    
    var body: some View {
        
        VStack {
            if let occupancy = viewModel.occupancy {
                Gauge(value: occupancy, in: 0...100) {
                    Text("BPM")
                } currentValueLabel: {
                    Text("\(Int(occupancy))")
                } minimumValueLabel: {
                    Text("\(Int(0))")
                        .foregroundStyle(.green)
                } maximumValueLabel: {
                    Text("\(Int(100))")
                        .foregroundStyle(.red)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(colorGauge(occupancy))
            } else {
                ProgressView()
            }
        }
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
        case 70...90:
                .orange
        case 90...200:
                .red
        default:
                .green
        }
    }
}

class OccupancyViewModel: NSObject, ObservableObject, RSFScrapperDelegate {
    @Published var occupancy: Double? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let scrapper = RSFScrapper()
    private var timer: Timer?

    override init() {
        super.init()
        scrapper.delegate = self
    }

    // MARK: - Automatic Refresh Control

    func startAutoRefresh() {
        refreshOccupancy()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true)  { [weak self] _ in
            self?.refreshOccupancy()
            
            //Change timer 
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Manual Refresh (For Testing or Optional Use)

    func refreshOccupancy() {
        isLoading = true
        errorMessage = nil
        scrapper.scrape(at: RSFScrapper.Constants.weightRoomURLString)
    }

    // MARK: - RSFScrapperDelegate Methods

    func rsfScrapperDidFinishScrapping(result: String?) {
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

    func rsfScrapperDidError(with errorDescription: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = errorDescription
        }
    }
}

#Preview {
    OccupancyView()
}
