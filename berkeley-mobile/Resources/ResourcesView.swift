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
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(BMColor.cardBackground))
            }
        }
    }
}

#Preview {
    ResourcesView()
}
