//
//  TodayTile.swift
//  berkeley-mobile
//
//  Created by Codex on 3/10/26.
//

import SwiftUI

struct TodayTileSpan: Equatable {
    let columns: Int
    let rows: Int

    init(columns: Int, rows: Int) {
        self.columns = max(1, columns)
        self.rows = max(1, rows)
    }

    func clamped(maxColumns: Int) -> TodayTileSpan {
        TodayTileSpan(columns: min(columns, maxColumns), rows: rows)
    }

    static let halfWidth = TodayTileSpan(columns: 2, rows: 2)
    static let fullWidth = TodayTileSpan(columns: 4, rows: 2)
}

struct TodayTileStyle {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    init(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
}

enum TodayTiles: CaseIterable {
    case weather

    func view() -> some View {
        switch self {
        case .weather:
            let weatherInfo = WeatherInfo(cityName: "Berkeley", currTemperature: "63", condition: "Sunny", highTemperature: "69", lowTemperature: "50")
            return TodayWeatherTileView(weatherInfo: weatherInfo)
        }
    }

    func viewAttributes() -> TodayTileAttributes {
        return switch self {
        case .weather:
            TodayTileAttributes(
                title: "Weather",
                subtitle: "Campus conditions",
                span: .halfWidth,
                style: TodayTileStyle(colors: [Color(red: 0.20, green: 0.52, blue: 0.87), Color(red: 0.50, green: 0.80, blue: 0.99)])
            )
        }
    }
}

extension TodayTiles: Identifiable {
    var id: String { String(describing: self) }
}

struct TodayTile: Identifiable {
    let id = UUID()
    let attributes: TodayTileAttributes
}

struct TodayTileAttributes: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let span: TodayTileSpan
    let style: TodayTileStyle
}

extension TodayTileAttributes {
    static let mockTiles: [TodayTileAttributes] = [
        TodayTileAttributes(
            title: "Schedule",
            subtitle: "Next classes and deadlines",
            span: .fullWidth,
            style: TodayTileStyle(colors: [Color(red: 0.24, green: 0.39, blue: 0.94), Color(red: 0.41, green: 0.75, blue: 0.98)])
        ),
        TodayTileAttributes(
            title: "Workout",
            subtitle: "Rec center snapshot",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.07, green: 0.63, blue: 0.56), Color(red: 0.47, green: 0.85, blue: 0.66)])
        ),
        TodayTileAttributes(
            title: "Dining",
            subtitle: "Lunch mockup",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.98, green: 0.55, blue: 0.30), Color(red: 0.99, green: 0.78, blue: 0.40)])
        ),
        TodayTileAttributes(
            title: "Focus",
            subtitle: "Study block placeholder",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.43, green: 0.24, blue: 0.83), Color(red: 0.76, green: 0.45, blue: 0.97)])
        ),
        TodayTileAttributes(
            title: "Weather",
            subtitle: "Campus conditions",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.20, green: 0.52, blue: 0.87), Color(red: 0.50, green: 0.80, blue: 0.99)])
        ),
        TodayTileAttributes(
            title: "Tasks",
            subtitle: "High priority items",
            span: .fullWidth,
            style: TodayTileStyle(colors: [Color(red: 0.84, green: 0.22, blue: 0.36), Color(red: 0.96, green: 0.46, blue: 0.58)])
        ),
        TodayTileAttributes(
            title: "Transit",
            subtitle: "Routes and ETA",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.05, green: 0.19, blue: 0.49), Color(red: 0.15, green: 0.51, blue: 0.87)])
        ),
        TodayTileAttributes(
            title: "Social",
            subtitle: "Evening plans",
            span: .halfWidth,
            style: TodayTileStyle(colors: [Color(red: 0.98, green: 0.33, blue: 0.61), Color(red: 0.99, green: 0.60, blue: 0.76)])
        )
    ]
}
