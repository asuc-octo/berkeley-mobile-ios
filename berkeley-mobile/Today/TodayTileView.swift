//
//  TodayTileView.swift
//  berkeley-mobile
//
//  Created by Codex on 3/10/26.
//

import SwiftUI

struct TodayTileView<Content: View>: View {
    let tile: TodayTileAttributes
    private let content: Content

    init(attributes: TodayTileAttributes, @ViewBuilder content: () -> Content) {
        self.tile = attributes
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(tile.style.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(20)
        }
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
    }
}

struct TodayMockTileContentView: View {
    let tile: TodayTileAttributes

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()

            Text(tile.title)
                .font(Font(BMFont.bold(24)))
                .foregroundStyle(.white)

            Text(tile.subtitle)
                .font(Font(BMFont.regular(15)))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(2)
        }
    }
}

struct TodayTileView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTileView(attributes: TodayTileAttributes.mockTiles[1]) {
            TodayMockTileContentView(tile: TodayTileAttributes.mockTiles[1])
        }
            .frame(width: 160, height: 160)
            .padding()
    }
}
