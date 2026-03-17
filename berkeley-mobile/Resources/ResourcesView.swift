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
        
                VStack(spacing: 0) {
                    if resourcesViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                        Spacer()
                    } else if resourcesViewModel.resourceCategories.isEmpty {
                        noResourcesAvailableView
                    } else {
                        // Search bar
                        ResourcesSearchBarView(
                            searchText: $resourcesViewModel.searchText,
                            isSearching: $resourcesViewModel.isSearching
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        .onChange(of: resourcesViewModel.searchText) {
                            resourcesViewModel.performSearch(resourcesViewModel.searchText)
                        }
                        
                        if resourcesViewModel.isSearching {
                            // Search results replace the category content
                            ResourcesSearchResultsView()
                        } else {
                            // Segmented control + category pages
                            BMSegmentedControlView(
                                tabNames: resourcesViewModel.resourceCategoryNames,
                                selectedTabIndex: $tabSelectedValue
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                            
                            TabView(selection: $tabSelectedValue) {
                                ForEach(Array(resourcesViewModel.resourceCategories.enumerated()), id: \.offset) { idx, category in
                                    ResourcePageView(
                                        resourceSections: category.sections,
                                        categoryName: category.name,
                                        onVisitWebsite: { resource, sectionTitle in
                                            let result = BMResourceSearchResult(
                                                resource: resource,
                                                sectionTitle: sectionTitle,
                                                categoryName: category.name
                                            )
                                            resourcesViewModel.saveRecentVisitedResource(result)
                                        }
                                    ).tag(idx)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                    }
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
}


// MARK: - ResourcePageView

struct ResourcePageView: View {
    var resourceSections: [BMResourceSection]
    var categoryName: String
    var onVisitWebsite: ((_ resource: BMResource, _ sectionTitle: String?) -> Void)?

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
                                                ResourceItemView(resource: resource, onVisitWebsite: {
                                                    onVisitWebsite?(resource, resourceSection.title)
                                                })
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
