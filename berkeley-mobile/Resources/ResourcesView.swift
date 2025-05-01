//
//  ResourcesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

// MARK: ResourcesView

struct ResourcesView: View {
    @StateObject private var resourcesVM = ResourcesViewModel()
    @State private var tabSelectedValue = 0
    @State private var shoutoutTabSelectedValue = 0
    @State private var isLoading = true
    
    init() {
        // Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : BMFont.bold(30)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobRight", xOffset: 30, width: 150, height: 150)
        
                VStack {
                    if isLoading {
                        ProgressView("Loading Resources...")
                    } else {

                        if resourcesVM.resourceCategories.isEmpty {
                            noResourcesAvailableView
                        } else {
                            SegmentedControlView(
                                tabNames: resourcesVM.resourceCategoryNames,
                                selectedTabIndex: $tabSelectedValue
                            )
                            .padding()
                            
                            TabView(selection: $tabSelectedValue) {
                                ForEach(Array(resourcesVM.resourceCategories.enumerated()), id: \.offset) { idx, category in
                                    ResourcePageView(resourceSections: category.sections).tag(idx)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        Spacer()
                    }
                }
                .navigationTitle("Resources")
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isLoading = false
                    }
                }

            }
            .background(Color(BMColor.cardBackground))
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
                    VStack(spacing: 0) {
                        ForEach(resourceSections, id: \.self) { resourceSection in
                            if let sectionHeaderText = resourceSection.title {
                                VStack(spacing: 0) {
                                    ResourcesSectionDropdown(title: sectionHeaderText, accentColor: .orange) {
                                        VStack(spacing: 0) {
                                            ForEach(resourceSection.resources, id: \.id) { resource in
                                                ResourceItemView(resource: resource)
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
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
