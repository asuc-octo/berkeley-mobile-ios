//
//  LibrariesTileView.swift
//  berkeley-mobile
//
//  Created by Lewis Yang on 4/27/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import Glur
import SwiftUI

struct LibrariesTileView: View {
    @InjectedObservable(\.librariesTileViewModel) private var viewModel

    var body: some View {
        Group {
            if viewModel.isFetching {
                progressView
            } else if viewModel.libraries.isEmpty {
                noLibrariesView
            } else if viewModel.isLocationAuthorizationRequestable {
                Button {
                    viewModel.requestLocationAuthorization()
                } label: {
                    locationPromptView
                }
                .buttonStyle(.plain)
            } else if viewModel.isLocationRestricted {
                locationPromptView
            } else if viewModel.userLocation == nil {
                progressView
            } else {
                let libraries = viewModel.nearestLibraries
                if let closestLibrary = libraries.first {
                    GeometryReader { proxy in
                        ZStack {
                            backgroundImageView(for: closestLibrary.library, proxy: proxy)
                                .glur(radius: 8.0, offset: 0.5, interpolation: 0.2, direction: .down)

                            // Dark overlay for better text readability
                            Color.black.opacity(0.3)

                            tileContentOverlay(for: libraries)
                        }
                    }
                } else {
                    noLibrariesView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func backgroundImageView(for library: BMLibrary, proxy: GeometryProxy) -> some View {
        if let imageURL = library.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                case .failure:
                    fallbackBackground
                default:
                    progressView
                }
            }
        } else {
            fallbackBackground
        }
    }

    private var fallbackBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.15, green: 0.25, blue: 0.45), Color(red: 0.25, green: 0.40, blue: 0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func tileContentOverlay(for libraries: [LibraryDistance]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                Text("Nearby Libraries")
                    .font(Font(BMFont.bold(15)))
            }

            Spacer()

            // Display the top 3 nearest libraries
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(libraries.enumerated()), id: \.element.library.id) { index, libraryDistance in
                    libraryRow(
                        library: libraryDistance.library,
                        distance: libraryDistance.distance,
                        isFirst: index == 0
                    )
                }
            }
        }
        .foregroundStyle(.white)
        .padding(16)
    }

    private func libraryRow(library: BMLibrary, distance: Double, isFirst: Bool) -> some View {
        // Distance sits under the name so the name gets the full row width
        VStack(alignment: .leading, spacing: 1) {
            Text(library.tileDisplayName)
                .font(Font(BMFont.medium(13)))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text("\(distance, specifier: "%.1f") mi")
                .font(Font(BMFont.regular(11)))
                .opacity(0.8)
        }
    }

    private var locationPromptView: some View {
        VStack(spacing: 6) {
            Image(systemName: "location.slash")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.7))
            Text("Turn on location to see nearby libraries")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private var noLibrariesView: some View {
        VStack {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.7))
            Text("No libraries available")
                .font(.caption)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var progressView: some View {
        ProgressView()
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Types

private extension BMLibrary {
    /// Short names for libraries whose Firestore name doesn't fit in a half-width tile, keyed by
    /// lowercased name with the trailing " library" removed.
    static let tileShortNames: [String: String] = [
        "bampfa film library & study center": "BAMPFA",
        "bancroft library/university archives": "Bancroft",
        "bioscience, natural resources & public health": "Bioscience",
        "chemistry and chemical engineering": "Chem & Physics",
        "earth sciences & map": "Earth Sciences",
        "institute of governmental studies": "Gov. Studies",
        "institute of transportation studies": "Transportation",
        "main (gardner) stacks": "Gardner Stacks",
        "newspapers & microforms": "Newspapers",
        "south/southeast asia": "South Asia",
    ]

    /// The library's name without the redundant "Library" suffix, shortened further if needed.
    var tileDisplayName: String {
        var trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.lowercased().hasSuffix(" library") {
            trimmedName = String(trimmedName.dropLast(" library".count))
        }
        return Self.tileShortNames[trimmedName.lowercased()] ?? trimmedName
    }
}

#Preview {
    LibrariesTileView()
        .frame(width: 180, height: 180)
}
