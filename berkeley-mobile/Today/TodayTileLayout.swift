//
//  TodayTileLayout.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.

import SwiftUI

private struct TodayTileSpanKey: LayoutValueKey {
    static let defaultValue = TodayTileSpan.fullWidth
}

extension View {
    func todayTileSpan(_ span: TodayTileSpan) -> some View {
        layoutValue(key: TodayTileSpanKey.self, value: span)
    }
}

struct TodayTilePlacementEngine {
    let columnCount: Int
    let spacing: CGFloat

    init(columnCount: Int = 4, spacing: CGFloat = 12) {
        self.columnCount = max(1, columnCount)
        self.spacing = spacing
    }

    func makeFrames(for spans: [TodayTileSpan], containerWidth: CGFloat) -> [CGRect] {
        guard containerWidth > 0 else {
            return Array(repeating: .zero, count: spans.count)
        }

        let totalSpacing = spacing * CGFloat(columnCount - 1)
        let columnWidth = (containerWidth - totalSpacing) / CGFloat(columnCount)
        let rowHeight = columnWidth

        var occupancy: [[Bool]] = []
        var frames: [CGRect] = []

        for span in spans.map({ $0.clamped(maxColumns: columnCount) }) {
            let placement = firstPlacement(for: span, occupancy: &occupancy)

            let x = CGFloat(placement.column) * (columnWidth + spacing)
            let y = CGFloat(placement.row) * (rowHeight + spacing)
            let width = (CGFloat(span.columns) * columnWidth) + (CGFloat(span.columns - 1) * spacing)
            let height = (CGFloat(span.rows) * rowHeight) + (CGFloat(span.rows - 1) * spacing)

            frames.append(CGRect(x: x, y: y, width: width, height: height))
        }

        return frames
    }

    private func firstPlacement(for span: TodayTileSpan, occupancy: inout [[Bool]]) -> (row: Int, column: Int) {
        var row = 0

        while true {
            for column in 0...(columnCount - span.columns) {
                if canPlace(span, atRow: row, column: column, occupancy: occupancy) {
                    mark(span, atRow: row, column: column, occupancy: &occupancy)
                    return (row, column)
                }
            }

            row += 1
        }
    }

    private func canPlace(_ span: TodayTileSpan, atRow row: Int, column: Int, occupancy: [[Bool]]) -> Bool {
        for rowIndex in row..<(row + span.rows) {
            for columnIndex in column..<(column + span.columns) {
                if rowIndex < occupancy.count, occupancy[rowIndex][columnIndex] {
                    return false
                }
            }
        }

        return true
    }

    private func mark(_ span: TodayTileSpan, atRow row: Int, column: Int, occupancy: inout [[Bool]]) {
        let requiredRows = row + span.rows
        while occupancy.count < requiredRows {
            occupancy.append(Array(repeating: false, count: columnCount))
        }

        for rowIndex in row..<(row + span.rows) {
            for columnIndex in column..<(column + span.columns) {
                occupancy[rowIndex][columnIndex] = true
            }
        }
    }
}

struct TodayTilingLayout: Layout {
    struct Cache {
        var width: CGFloat = .zero
        var spans: [TodayTileSpan] = []
        var frames: [CGRect] = []
    }

    private let placementEngine: TodayTilePlacementEngine

    init(columnCount: Int = 4, spacing: CGFloat = 12) {
        placementEngine = TodayTilePlacementEngine(columnCount: columnCount, spacing: spacing)
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache(spans: subviews.map { $0[TodayTileSpanKey.self] })
    }

    func updateCache(_ cache: inout Cache, subviews: Subviews, proposal: ProposedViewSize) {
        let spans = subviews.map { $0[TodayTileSpanKey.self] }
        let width = proposal.replacingUnspecifiedDimensions().width

        guard cache.width != width || cache.spans != spans else {
            return
        }

        cache.width = width
        cache.spans = spans
        cache.frames = placementEngine.makeFrames(for: spans, containerWidth: width)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        updateCache(&cache, subviews: subviews, proposal: proposal)

        let contentHeight = cache.frames.map(\.maxY).max() ?? 0
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: contentHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        updateCache(&cache, subviews: subviews, proposal: ProposedViewSize(width: bounds.width, height: bounds.height))

        for (index, subview) in subviews.enumerated() where index < cache.frames.count {
            let frame = cache.frames[index].offsetBy(dx: bounds.minX, dy: bounds.minY)
            subview.place(
                at: frame.origin,
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }
}
