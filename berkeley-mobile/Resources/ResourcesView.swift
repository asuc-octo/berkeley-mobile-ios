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
    
    init() {
        // Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : BMFont.bold(30)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobRight", xOffset: 30, width: 150, height: 150)
        
                VStack {
                    if !resourcesVM.shoutouts.isEmpty  {
                        resourceShoutoutsTabView
                    }
                    
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
                .navigationTitle("Resources")
            }
            .background(Color(BMColor.cardBackground))
        }
    }
    
    private var noResourcesAvailableView: some View {
        VStack {
            Spacer()
            Text("No Resources Available")
                .font(Font(BMFont.bold(21)))
            Spacer()
        }
    }
    
    private var resourceShoutoutsTabView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    shoutoutTabSelectedValue -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.gray)
                    .fontWeight(.heavy)
            }
            .opacity(shoutoutTabSelectedValue - 1 >= 0 ? 1 : 0)
            .disabled(shoutoutTabSelectedValue - 1 >= 0 ? false : true)
            
            TabView(selection: $shoutoutTabSelectedValue) {
                ForEach(Array(resourcesVM.shoutouts.enumerated()), id: \.element) { idx, shoutOut in
                    ResourceShoutoutView(callout: shoutOut)
                        .tag(idx)
                }
            }
            .frame(height: 150)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Button(action: {
                withAnimation {
                    shoutoutTabSelectedValue += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .fontWeight(.heavy)
            }
            .opacity(shoutoutTabSelectedValue + 1 < resourcesVM.shoutouts.count ? 1 : 0)
            .disabled(shoutoutTabSelectedValue + 1 < resourcesVM.shoutouts.count ? false : true)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
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
                List {
                    ForEach(resourceSections, id: \.self) { resourceSection in
                        DisclosureGroup(
                            content: {
                                VStack(alignment: .leading) {
                                    ForEach(resourceSection.resources, id: \.id) { resource in
                                        ResourceLinkView(resource: resource)
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            },
                            label: {
                                if let sectionHeaderText = resourceSection.title {
                                    Text(sectionHeaderText)
                                        .bold()
                                        .font(Font(BMFont.bold(25)))
                                }
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}


// MARK: - ResourceLinkView

struct ResourceLinkView: View {
    var resource: BMResource
    
    @State private var isPresentingWebView = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray, lineWidth: 1)
            .frame(height: 130)
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text("\(resource.name)")
                            .font(Font(BMFont.regular(17)))
                            .fontWeight(.heavy)
                        Spacer()
                    }
                    .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .bold()
                        .font(.system(size: 13))
                }
                .padding()
            )
            .onTapGesture {
                isPresentingWebView.toggle()
            }
            .fullScreenCover(isPresented: $isPresentingWebView) {
                if let url = resource.url {
                    SafariWebView(url: url)
                        .edgesIgnoringSafeArea(.all)
                }
            }
    }
}


// MARK: - ResourceShoutoutView

struct ResourceShoutoutView: View {
    var callout: BMResourceShoutout
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.green.opacity(0.8))
            .frame(width: 300, height: 100)
            .overlay(
                VStack(alignment: .leading) {
                    HStack {
                        Text(callout.title)
                            .bold()
                            .font(Font(BMFont.regular(23)))
                        Spacer()
                        
                        if callout.url != nil {
                            Button(action: {}) {
                                Image(systemName: "link")
                            }
                        }
                    }
                    Spacer()
                    Text(callout.subtitle)
                        .font(Font(BMFont.regular(13)))
                }
                .foregroundStyle(.white)
                .padding()
            )
    }
}

#Preview {
    ResourcesView()
}
