//
//  FitnessView.swift
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
            Text("RSF Weight Room Occupancy")
                .font(.title)
                .padding()

            if let occupancy = viewModel.occupancy {
                Gauge(value: occupancy, in: 0...100) {
                    Text("Occupancy")
                } currentValueLabel: {
                    Text("\(occupancy, specifier: "%.0f")%")
                }
                .gaugeStyle(.accessoryCircular)
                .padding()
            } else if viewModel.isLoading {
                ProgressView("Loading occupancy...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
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
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.refreshOccupancy()
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
        scrapper.getOccupancy()
    }

    // MARK: - RSFScrapperDelegate Methods

    func rsfScrapperDidFinishScrapping(result: String?) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let result = result, let occupancy = Double(result.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "%", with: "")) {
                self.occupancy = occupancy
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
