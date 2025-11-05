//
//  GuideDetailView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GuideDetailView: View {
    @Environment(GuidesViewModel.self) private var viewModel
    
    var guide: Guide
    
    var body: some View {
        List(guide.places) { place in
            Section {
                GuideDetailRowHeaderView(place: place)
                Text(place.description)
                    .foregroundStyle(.secondary)
                    .font(Font(BMFont.regular(15)))
                    .padding()
            }
            .listRowSpacing(10)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(guide.name)
                        .bold()
                    Text("^[\(guide.places.count) Place](inflect: true)")
                        .font(.caption)
                }
                .padding(.top, 10)
            }
        }
    }
}


// MARK: - GuideDetailRowHeaderView

struct GuideDetailRowHeaderView: View {
    @Environment(GuidesViewModel.self) private var viewModel
    
    var place: GuidePlace
    
    @State private var isPresentingWebView = false
    
    var body: some View {
        ZStack {
            BMCachedAsyncImageView(imageURL: place.imageURL, aspectRatio: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Text(place.name)
                        .font(Font(BMFont.bold(20)))
                    Spacer()
                    
                    if place.hasWebsite {
                        GuideDetailRowActionItemView(systemName: "link", backgroundColor: .purple) {
                            isPresentingWebView.toggle()
                        }
                    }
                    
                    if place.hasPhoneNumber {
                        GuideDetailRowActionItemView(systemName: "phone", backgroundColor: .green) {
                            viewModel.call(place)
                        }
                    }
                   
                    if place.hasCoordinate {
                        GuideDetailRowActionItemView(systemName: "map", backgroundColor: .blue) {
                            viewModel.openPlaceInMaps(for: place)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .frame(height: 50)
                .background(.ultraThinMaterial)
            }
        }
        .fullScreenCover(isPresented: $isPresentingWebView) {
            if let websiteURLString = place.websiteURLString, let url = URL(string: websiteURLString) {
                SafariWebView(url: url)
            }
        }
    }
}


// MARK: - GuideDetailRowActionItemView

struct GuideDetailRowActionItemView: View {
    @Environment(GuidesViewModel.self) private var viewModel

    var systemName: String
    var backgroundColor: Color
    
    var actionHandler: () -> Void
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(6)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                actionHandler()
            }
    }
}
