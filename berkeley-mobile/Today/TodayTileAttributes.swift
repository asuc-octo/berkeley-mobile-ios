//
//  TodayTile.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.

import SwiftUI

struct TodayTile: Identifiable {
    let id = UUID()
    let attributes: TodayTileAttributes
}

struct TodayTileAttributes: Identifiable {
    let id = UUID()
    let span: TodayTileSpan
    let displayedStyleName: TodayTileStyle.Name
    let styles: [TodayTileStyle.Name: TodayTileStyle]

    var displayedStyle: TodayTileStyle {
        return styles[displayedStyleName] ?? TodayTileStyle.defaultStyle
    }
}

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
    enum Name: Hashable {
        case defaultName
    }

    static let defaultStyle: TodayTileStyle = .init(colors: [
        Color(.systemGroupedBackground),
        Color(.secondarySystemGroupedBackground)
    ])

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
    case dining

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .weather:
            TodayWeatherTileView()
        case .dining:
            TodayDiningTileView()
        }
    }

    func viewAttributes(for displayedStyleName: TodayTileStyle.Name = TodayTileStyle.Name.defaultName) -> TodayTileAttributes {
        return switch self {
        case .weather:
            TodayTileAttributes(
                span: .halfWidth,
                displayedStyleName: displayedStyleName,
                styles: [TodayTileStyle.Name.defaultName: TodayTileStyle(colors: [
                    Color(red: 0.20, green: 0.52, blue: 0.87),
                    Color(red: 0.50, green: 0.80, blue: 0.99)])]
            )
        case .dining:
            TodayTileAttributes(
                span: .halfWidth,
                displayedStyleName: displayedStyleName,
                styles: [TodayTileStyle.Name.defaultName: TodayTileStyle(colors: [
                    Color(red: 0.95, green: 0.45, blue: 0.20),
                    Color(red: 0.99, green: 0.70, blue: 0.35)])]
            )
        }
    }
}

extension TodayTiles: Identifiable {
    var id: String { String(describing: self) }
}
