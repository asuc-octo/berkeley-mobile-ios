//
//  TodayWeatherTileView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/9/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct WeatherInfo {
    let cityName: String
    let currTemperature: String
    let condition: String
    let highTemperature: String
    let lowTemperature: String
}

struct TodayWeatherTileView: View {
    let weatherInfo: WeatherInfo
    @State private var currTemperature: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text(weatherInfo.cityName)
                .font(.headline)

            Text("\(currTemperature)°")
                .contentTransition(.numericText(value: Double(currTemperature)))
                .font(.largeTitle)
            Spacer()
            Image(systemName: "sun.max.fill")
                .foregroundStyle(.yellow)
            Group {
                Text(weatherInfo.condition)
                    .font(.callout)
                HStack {
                    Text("H:\(weatherInfo.highTemperature)°")
                    Text("L:\(weatherInfo.lowTemperature)°")
                }
                .font(.callout)
            }
            .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .onAppear {
            currTemperature = Int(weatherInfo.currTemperature) ?? 0
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.easeIn) {
                currTemperature += 1
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let weatherTile = TodayTileAttributes(
        title: "Weather",
        subtitle: "Campus conditions",
        span: .halfWidth,
        style: TodayTileStyle(colors: [Color(red: 0.20, green: 0.52, blue: 0.87), Color(red: 0.50, green: 0.80, blue: 0.99)])
    )
    let weatherInfo = WeatherInfo(cityName: "Berkeley", currTemperature: "63", condition: "Sunny", highTemperature: "69", lowTemperature: "50")

    TodayTileView(attributes: weatherTile) {
        TodayWeatherTileView(weatherInfo: weatherInfo)
    }
    .todayTileSpan(weatherTile.span)
    .frame(width: 170, height: 170)
    .padding()

}
