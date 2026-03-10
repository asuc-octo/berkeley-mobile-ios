//
//  TodayView.swift
//  berkeley-mobile
//
//  Created by Codex on 3/10/26.
//

import SwiftUI

struct TodayView: View {
    private let tiles: [TodayTileAttributes]

    init(tiles: [TodayTileAttributes] = TodayTileAttributes.mockTiles) {
        self.tiles = tiles
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView

                    TodayTilingLayout(columnCount: 4, spacing: 12) {
                        ForEach(TodayTiles.allCases) { tile in
                            let viewAttributes = tile.viewAttributes()
                            TodayTileView(attributes: viewAttributes) {
                                tile.view()
                            }
                            .todayTileSpan(viewAttributes.span)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your day at a glance")
                .font(Font(BMFont.bold(28)))
                .foregroundStyle(Color.primary)

            Text("Mock widget tiles sized on a 4-column grid.")
                .font(Font(BMFont.regular(16)))
                .foregroundStyle(Color.primary.opacity(0.7))
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.secondarySystemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
