//
//  GuidesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GuidesView: View {
    @State private var viewModel = GuidesViewModel()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
            Spacer()
        } else if viewModel.guides.isEmpty {
            Text("No Guides Available")
                .font(Font(BMFont.bold(20)))
                .foregroundStyle(.gray)
            Spacer()
        } else {
            List(viewModel.guides) { guide in
                NavigationLink {
                    GuideDetailView(guide: guide)
                        .containerBackground(.clear, for: .navigation)
                        .environment(viewModel)
                } label: {
                    GuideRowView(guide: guide)
                }
                .disabled(guide.places.isEmpty)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}


// MARK: - GuideRowView

struct GuideRowView: View {
    var guide: Guide
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 20) {
                GuidePlacesStackedCollageView(guide: guide)
                    .frame(width: proxy.size.width / 4)
               
                VStack(alignment: .leading, spacing: 10) {
                    Text(guide.name)
                        .font(Font(BMFont.regular(24)))
                        .bold()
                    Text(guide.description)
                        .foregroundStyle(.secondary)
                        .font(Font(BMFont.regular(15)))
                    Text(guide.places.isEmpty ? "No Places" : "^[\(guide.places.count) Place](inflect: true)")
                        .font(Font(BMFont.regular(15)))
                        .fontWeight(.semibold)
                }
                .frame(width: proxy.size.width / (5 / 3.5))
                
                if !guide.places.isEmpty {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 200)
    }
}


// MARK: - GuidePlacesStackedCollageView

struct GuidePlacesStackedCollageView: View {
    var guide: Guide
    
    // First angle corresponds to the furthest back image
    private let angles: [CGFloat] = [-10.0, 10.0, 0.0]
    
    var body: some View {
        ZStack {
            if guide.places.isEmpty {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray)
                    .frame(width: 80, height: 150)
                    .rotationEffect(.degrees(0))
            } else {
                let items = Array(guide.places.prefix(3).reversed())
                ForEach(Array(zip(items, angles.prefix(items.count)).enumerated()), id: \.offset) { _, pair in
                    let (place, angle) = pair
                    BMCachedAsyncImageView(imageURL: place.imageURL, aspectRatio: .fill)
                        .frame(width: 80, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .rotationEffect(.degrees(angle))
                }
            }
        }
    }
}

#Preview {
    GuidesView()
}
