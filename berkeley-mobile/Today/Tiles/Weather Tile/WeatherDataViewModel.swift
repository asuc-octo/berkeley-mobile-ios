//
//  WeatherDataViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/29/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import CoreLocation
import Foundation
import WeatherKit
import os

@MainActor
@Observable
class WeatherDataViewModel {

    var currentWeather: CurrentWeather?
    var dailyForecast: DayWeather?
    var showNotAvailable = false

    @ObservationIgnored
    private let service = WeatherService.shared
    @ObservationIgnored
    private let berkeleyLocation = CLLocation(latitude: 37.8716, longitude: -122.2727)
    @ObservationIgnored
    private var refreshInterval: TimeInterval
    @ObservationIgnored
    private var scheduledTimer: Timer?

    init(refreshInterval: TimeInterval = TimeInterval(minutes: 5)) {
        self.refreshInterval = refreshInterval
        scheduledTimer = createScheduledTimer()
        scheduledTimer?.fire()
    }

    func getCurrentWeather() async -> CurrentWeather? {
        let currentWeather = await Task.detached(priority: .userInitiated) { () -> CurrentWeather? in
            do {
                let forecast = try await self.service.weather(
                    for: self.berkeleyLocation,
                    including: .current)
                return forecast
            } catch {
                Logger.weatherDataViewModel.error("Cannot fetch current weather: \(error.localizedDescription)")
                await MainActor.run {
                    self.showNotAvailable = true
                }
                return nil
            }
        }.value
        return currentWeather
    }

    func getDailyForecast() async -> Forecast<DayWeather>? {
        let dayWeather = await Task.detached(priority: .userInitiated) { () -> Forecast<DayWeather>? in
            do {
                let forecast = try await self.service.weather(
                    for: self.berkeleyLocation,
                    including: .daily)
                return forecast
            } catch {
                Logger.weatherDataViewModel.error("Cannot fetch current weather: \(error.localizedDescription)")
                await MainActor.run {
                    self.showNotAvailable = true
                }
                return nil
            }
        }.value
        return dayWeather
    }

    func getCurrentAndDailyWeather() async {
        do {
            let (current, daily) = try await service.weather(for: berkeleyLocation, including: .current, .daily)
            currentWeather = current
            dailyForecast = daily.first
        } catch {
            Logger.weatherDataViewModel.error("Cannot fetch current and daily weather: \(error.localizedDescription)")
            showNotAvailable = true
        }
    }

    func stopFetchingData() {
        scheduledTimer?.invalidate()
    }
    
    private func createScheduledTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                if self.currentWeather == nil, self.dailyForecast == nil {
                    await self.getCurrentAndDailyWeather()
                    return
                }

                if self.currentWeather == nil {
                    self.currentWeather = await self.getCurrentWeather()
                }

                if self.dailyForecast == nil {
                    self.dailyForecast = (await self.getDailyForecast())?.first
                }
            }
        }
    }
}
