//
//  TodayWeatherTileView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/9/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct TodayWeatherTileView: View {
    private struct Constants {
        static let fallbackCurrentTemperature = Measurement(value: 69.0, unit: UnitTemperature.fahrenheit)
        static let fallbackHighTemperature = Measurement(value: 70.0, unit: UnitTemperature.fahrenheit)
        static let fallbackLowTemperature = Measurement(value: 40.0, unit: UnitTemperature.fahrenheit)
    }

    @InjectedObservable(\.weatherDataViewModel) private var viewModel

    private var shouldRedact: Bool {
        viewModel.currentWeather == nil && viewModel.dailyForecast == nil
    }

    private var temperatureFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .temperatureWithoutUnit
        formatter.locale = .autoupdatingCurrent
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }

    var body: some View {
        Group {
            if viewModel.showNotAvailable {
                Text("Weather is not currently available.")
                    .font(.caption)
                    .foregroundStyle(.white)
            } else  {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Berkeley")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: viewModel.currentWeather?.symbolName ?? "sun")
                            .font(.callout)
                    }

                    Text(getFormattedTemperatureString(viewModel.currentWeather?.temperature ?? Constants.fallbackCurrentTemperature))
                        .font(.largeTitle)
                    Spacer()

                    Group {
                        Text(viewModel.currentWeather?.condition.description ?? "Sunny")
                            .font(.callout)
                        HStack {
                            Text("H:\(getFormattedTemperatureString(viewModel.dailyForecast?.highTemperature ?? Constants.fallbackHighTemperature))")
                            Text("L:\(getFormattedTemperatureString(viewModel.dailyForecast?.lowTemperature ?? Constants.fallbackLowTemperature))")
                        }
                    }
                    .font(.callout)
                    .fontWeight(.semibold)
                }
                .redacted(reason: shouldRedact ? .placeholder : [])
                .foregroundStyle(.white)
            }
        }
        .onDisappear {
            viewModel.stopFetchingData()
        }
    }

    private func getFormattedTemperatureString(_ temperature: Measurement<UnitTemperature>) -> String {
        let preferredTemperatureUnit = UnitTemperature(forLocale: .autoupdatingCurrent, usage: .weather)
        let convertedTemperature = temperature.converted(to: preferredTemperatureUnit)
        return temperatureFormatter.string(from: convertedTemperature)
    }
}
