//
//  TodayView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.

import SwiftUI

struct TodayView: View {

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : BMFont.bold(30)]
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
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your day at a glance")
                .font(Font(BMFont.bold(22)))
                .foregroundStyle(Color.primary)

            Text("Tiles surface the key events and highlights of your day.")
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

#Preview {
    TodayView()
}
