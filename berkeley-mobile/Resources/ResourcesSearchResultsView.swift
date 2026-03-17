//
//  ResourcesSearchResultsView.swift
//  berkeley-mobile
//
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct ResourcesSearchResultsView: View {
    @InjectedObject(\.resourcesViewModel) private var viewModel
    @State private var isPresentingWebView = false
    @State private var presentedURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    recentSearchesSection
                } else if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.immediately)
        .fullScreenCover(isPresented: $isPresentingWebView) {
            if let url = presentedURL {
                SafariWebView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    // MARK: - Recently Visited

    @ViewBuilder
    private var recentSearchesSection: some View {
        if !viewModel.recentVisitedResources.isEmpty {
            HStack {
                Text("Recents")
                    .font(Font(BMFont.regular(14)))
                Spacer()
                Button(action: {
                    withAnimation(.snappy) {
                        viewModel.clearAllRecentVisited()
                    }
                }) {
                    Text("Clear all")
                        .font(Font(BMFont.regular(14)))
                }
            }
            .padding(.top, 16)

            ForEach(viewModel.recentVisitedResources.prefix(3)) { result in
                Button {
                    viewModel.saveRecentVisitedResource(result)
                    if let url = result.resource.url {
                        presentedURL = url
                        isPresentingWebView = true
                    }
                } label: {
                    HStack {
                        Group {
                            if #available(iOS 18.0, *) {
                                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                    .resizable()
                            } else {
                                Image(systemName: "clock")
                                    .resizable()
                            }
                        }
                        .scaledToFit()
                        .frame(width: 24)
                        .foregroundStyle(Color(BMColor.searchBarIconColor))
                        .frame(width: 52)

                        Text(result.resource.name)
                            .font(Font(BMFont.regular(16)))
                            .frame(height: 36)

                        Spacer()
                    }
                    .padding(10)
                    .frame(height: 54.0)
                }
                .buttonStyle(SearchResultsListRowButtonStyle())
            }
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No results found")
                .font(Font(BMFont.medium(16)))
                .foregroundStyle(.secondary)
            Text("Try a different search term")
                .font(Font(BMFont.regular(14)))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        ForEach(viewModel.searchResults) { result in
            VStack(alignment: .leading, spacing: 4) {
                // Category and section context label
                Text(resultLabel(for: result))
                    .font(Font(BMFont.medium(12)))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                // Reuse the same ResourceItemView used in the normal browse view
                ResourceItemView(resource: result.resource, onVisitWebsite: {
                    viewModel.saveRecentVisitedResource(result)
                })
            }
        }
    }

    private func resultLabel(for result: BMResourceSearchResult) -> String {
        if let section = result.sectionTitle {
            return "\(result.categoryName) · \(section)"
        }
        return result.categoryName
    }
}
