//
//  GuidesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GuidesView: View {
    @Environment(GuidesViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
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
                .contentMargins(.top, 0)
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear {
            viewModel.fetchGuides()
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



#Preview {
    GuidesView()
}
