//
//  ResourcesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct ResourcesView: View {
    @StateObject private var resourcesViewModel = ResourcesViewModel()
    @State private var tabSelectedValue = 0
    @State private var searchText = ""
    
    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var searchResults: [(categoryName: String, section: BMResourceSection)] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
 
        return resourcesViewModel.resourceCategories.flatMap { category in
            category.sections.filter { section in
                let titleMatch = section.title?.localizedCaseInsensitiveContains(query) ?? false
                let resourceMatch = section.resources.contains {
                    $0.name.localizedCaseInsensitiveContains(query)
                }
                return titleMatch || resourceMatch
            }
            .map { (categoryName: category.name, section: $0) }
        }
    }

    
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
                        BMSegmentedControlView(
                            tabNames: resourcesViewModel.resourceCategoryNames,
                            selectedTabIndex: $tabSelectedValue
                        )
                        .padding()
                        
                        TabView(selection: $tabSelectedValue) {
                            ForEach(Array(resourcesViewModel.resourceCategories.enumerated()), id: \.offset) { idx, category in
                                ResourcePageView(resourceSections: category.sections).tag(idx)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                    Spacer()
                }
                .navigationTitle("Resources")
            }
            .background(Color(BMColor.cardBackground))
            .presentAlert(alert: $resourcesViewModel.alert)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search resources..."
            )
            .animation(.default, value: isSearching)

        }
    }
    
    // MARK: - Search Results View
 
    @ViewBuilder
    private var searchResultsView: some View {
        if searchResults.isEmpty {
            BMContentUnavailableView(
                iconName: "magnifyingglass",
                title: "No Results",
                subtitle: "No resources found for \"\(searchText.trimmingCharacters(in: .whitespaces))\""
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .transition(.opacity)
        } else {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(searchResults, id: \.section) { result in
                        if let sectionTitle = result.section.title {
                            VStack(alignment: .leading, spacing: 4) {
                                // Category label above each matched section
                                Text(result.categoryName)
                                    .font(Font(BMFont.regular(12)))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
 
                                ResourcesSectionDropdown(title: sectionTitle, accentColor: .orange) {
                                    VStack(spacing: 0) {
                                        ForEach(result.section.resources, id: \.id) { resource in
                                            ResourceItemView(resource: resource)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(BMColor.cardBackground))
            .transition(.opacity)
        }
    }

    // MARK: - Empty State
    
    private var noResourcesAvailableView: some View {
        BMContentUnavailableView(
                iconName: "exclamationmark.triangle",
                title: "No Resources Available",
                subtitle: "Try again later."
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(y: -45)
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
