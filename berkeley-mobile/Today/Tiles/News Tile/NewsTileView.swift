//
//  NewsTileView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/6/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import Glur
import SwiftUI

struct NewsTileView: View {
    @InjectedObservable(\.newsDataViewModel) private var viewModel

    private var shouldRedact: Bool {
        !viewModel.showNotAvailable && viewModel.newsArticles.isEmpty
    }

    var body: some View {
        Group {
            if viewModel.showNotAvailable {
                notAvailableView
            } else if let randomArticle = viewModel.newsArticles.randomElement() {
                GeometryReader { proxy in
                    ZStack {
                        backgroundImageView(for: randomArticle, proxy: proxy)
                            .glur(radius: 8.0, offset: 0.5, interpolation: 0.2, direction: .down)
                        tileTextOverlay(for: randomArticle)
                    }
                }
                .redacted(reason: shouldRedact ? .placeholder : [])
            } else {
                progressView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func backgroundImageView(for article: NewsArticle, proxy: GeometryProxy) -> some View {
        if let articleURL = article.article.imageURL {
            AsyncImage(url: URL(string: articleURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            } placeholder: {
                progressView
            }
        }
    }

    private func tileTextOverlay(for article: NewsArticle) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Daily Cal")
                    .font(Font(BMFont.bold(15)))
            }
            Spacer()
            Text(article.article.title ?? "")
                .font(Font(BMFont.mediumItalic(15)))
        }
        .foregroundStyle(.white)
        .padding()
    }

    private var notAvailableView: some View {
        Text("News Tile is not currently available.")
            .font(.caption)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var progressView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NewsTileView()
}
