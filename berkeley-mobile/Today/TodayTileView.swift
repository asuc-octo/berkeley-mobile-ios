//
//  TodayTileView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/10/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.

import SwiftUI

struct TodayTileView<Content: View>: View {
    let tileAttributes: TodayTileAttributes
    private let content: Content
    private let tileShape = RoundedRectangle(cornerRadius: 28, style: .continuous)

    init(attributes: TodayTileAttributes, @ViewBuilder content: () -> Content) {
        self.tileAttributes = attributes
        self.content = content()
    }

    var body: some View {
        ZStack {
            tileShape
                .fill(tileAttributes.displayedStyle.gradient)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(tileAttributes.contentPadding)
        }
        .clipShape(tileShape)
        .overlay(
            tileShape
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TodayTileView(attributes: TodayTiles.weather.viewAttributes()) {
        TodayTiles.weather.view()
    }
    .frame(width: 160, height: 160)
    .padding()
}
