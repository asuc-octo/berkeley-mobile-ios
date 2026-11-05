//
//  SportsTileView.swift
//  berkeley-mobile
//
//  Created by ASUC OCTO on 7/28/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct SportsTileView: View {
    @InjectedObservable(\.sportsDataViewModel) private var viewModel

    private var shouldRedact: Bool {
        !viewModel.showNotAvailable && viewModel.games.isEmpty
    }

    var body: some View {
        Group {
            if viewModel.showNotAvailable {
                notAvailableView
            } else if let game = viewModel.games.first {
                gameView(for: game)
                    .redacted(reason: shouldRedact ? .placeholder : [])
            } else {
                progressView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func gameView(for game: SportGame) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(game.sport)
                    .font(Font(BMFont.bold(13)))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                statusBadge(for: game)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                teamRow(name: game.homeTeam, score: game.homeScore)
                teamRow(name: game.awayTeam, score: game.awayScore)
            }

            if let location = game.location {
                Text(location)
                    .font(Font(BMFont.regular(11)))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.white)
        .padding()
    }

    private func teamRow(name: String, score: Int?) -> some View {
        HStack {
            Text(name)
                .font(Font(BMFont.medium(14)))
                .lineLimit(1)
            Spacer()
            if let score {
                Text("\(score)")
                    .font(Font(BMFont.bold(14)))
            }
        }
    }

    @ViewBuilder
    private func statusBadge(for game: SportGame) -> some View {
        let (label, color) = statusInfo(for: game.status)
        Text(label)
            .font(Font(BMFont.bold(11)))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.3))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func statusInfo(for status: SportGame.SportGameStatus) -> (String, Color) {
        switch status {
        case .upcoming:
            return ("Upcoming", .white)
        case .inProgress:
            return ("Live", .green)
        case .final_:
            return ("Final", .white.opacity(0.7))
        }
    }

    private var notAvailableView: some View {
        Text("Sports Tile is not currently available.")
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
    SportsTileView()
}
