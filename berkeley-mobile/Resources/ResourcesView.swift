//
//  ResourcesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct ResourcesView: View {
    @InjectedObject(\.resourcesViewModel) private var resourcesViewModel

    @State private var tabSelectedValue = 0
    
    init() {
        // Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : BMFont.bold(30)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobRight", xOffset: 30, width: 150, height: 150)
        
                VStack {
                    if resourcesViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                    } else if resourcesViewModel.resourceCategories.isEmpty {
                        noResourcesAvailableView
                    } else {
                        if #available(iOS 26.0, *) {
                            ResourcesSearchContainer(resourceCategories: resourcesViewModel.resourceCategories)
                        } else {
                            resourcesTabView(categories: resourcesViewModel.resourceCategories)
                        }
                    }
                    Spacer()
                }
                .navigationTitle("Resources")
            }
            .background(Color(BMColor.cardBackground))
            .presentAlert(alert: $resourcesViewModel.alert)
        }
    }
    
    private var noResourcesAvailableView: some View {
        BMContentUnavailableView(
                iconName: "exclamationmark.triangle",
                title: "No Resources Available",
                subtitle: "Try again later."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(y: -45)
    }

    @ViewBuilder
    private func resourcesTabView(categories: [BMResourceCategory]) -> some View {
        BMSegmentedControlView(
            tabNames: categories.map { $0.name },
            selectedTabIndex: $tabSelectedValue
        )
        .padding()
        
        TabView(selection: $tabSelectedValue) {
            ForEach(Array(categories.enumerated()), id: \.offset) { idx, category in
                ResourcePageView(resourceSections: category.sections).tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

@available(iOS 26.0, *)
private struct ResourcesSearchContainer: View {
    let resourceCategories: [BMResourceCategory]
    @StateObject private var searchViewModel = ResourcesSearchViewModel()
    @State private var searchText = ""
    @State private var selectedTabValue = 0
    @State private var pendingSearchTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            searchBar

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack {
                    BMSegmentedControlView(
                        tabNames: resourceCategories.map { $0.name },
                        selectedTabIndex: $selectedTabValue
                    )
                    .padding()

                    TabView(selection: $selectedTabValue) {
                        ForEach(Array(resourceCategories.enumerated()), id: \.offset) { idx, category in
                            ResourcePageView(resourceSections: category.sections).tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            } else {
                searchResultsView
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: searchText)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(BMColor.searchBarIconColor))

            TextField("Search campus resources", text: $searchText)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    searchNow()
                }
                .onChange(of: searchText) { newValue in
                    pendingSearchTask?.cancel()

                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        searchViewModel.clear()
                        return
                    }

                    pendingSearchTask = Task {
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        await searchViewModel.search(query: trimmed, in: resourceCategories)
                    }
                }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(BMColor.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func searchNow() {
        pendingSearchTask?.cancel()

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchViewModel.clear()
            return
        }

        Task {
            await searchViewModel.search(query: trimmed, in: resourceCategories)
        }
    }

    @ViewBuilder
    private var searchResultsView: some View {
        if searchViewModel.isSearching {
            VStack {
                ProgressView()
                    .controlSize(.large)
                    .padding(.top, 20)
                Text("Searching resources...")
                    .font(Font(BMFont.regular(15)))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else if let error = searchViewModel.searchError {
            Text(error)
                .foregroundColor(.red)
                .font(Font(BMFont.regular(15)))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
        } else if searchViewModel.results.isEmpty {
            Text("No results for \"\(searchText)\".")
                .foregroundColor(.secondary)
                .font(Font(BMFont.regular(16)))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(searchViewModel.results, id: \.id) { resource in
                        ResourceItemView(resource: resource)
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}


// MARK: - ResourcePageView

struct ResourcePageView: View {
    var resourceSections: [BMResourceSection]

    var body: some View {
        Group {
            if resourceSections.isEmpty {
                Text("No Content Available")
                    .bold()
                    .font(Font(BMFont.regular(30)))
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(resourceSections, id: \.self) { resourceSection in
                            if let sectionHeaderText = resourceSection.title {
                                    ResourcesSectionDropdown(title: sectionHeaderText, accentColor: .orange) {
                                        VStack(spacing: 0) {
                                            ForEach(resourceSection.resources, id: \.id) { resource in
                                                ResourceItemView(resource: resource)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .background(Color(BMColor.cardBackground))
            }
        }
    }
}

#Preview {
    ResourcesView()
}
