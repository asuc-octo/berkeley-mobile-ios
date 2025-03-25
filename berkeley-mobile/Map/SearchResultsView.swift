//
//  SearchResultsView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/17/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    private let searchResultsListTopPadding: CGFloat = 128 // SearchBarTopMargin (74) + SearchBarHeight (54)
    
    var body: some View {
        ZStack {
            if viewModel.isSearchBarFocused {
                // Masking view behind, when search bar is focused:
                VStack{}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
            }
            
            VStack {
                switch viewModel.state {
                case .idle:
                    BMContentUnavailableView(iconName: "text.magnifyingglass", title: "Type Something", subtitle: "Search for anything you need.")
                    
                case .loading:
                    ProgressView()
                    
                case .populated:
                    populatedList
                        .padding(.top, searchResultsListTopPadding)
                        .padding(.horizontal, 21)
                        .padding(.bottom, 96)
                    
                case .empty:
                    BMContentUnavailableView(iconName: "magnifyingglass", title: "Nothing Found!", subtitle: "Try a different keyword.")
                    
                case .error(let error):
                    BMContentUnavailableView(iconName: "exclamationmark.circle", title: "An Error Occurred", subtitle: error.localizedDescription)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
        .background(.clear)
    }
    
    private var populatedList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(viewModel.state.placemarks, id: \.location) { placemark in
                    Button(action: {
                        viewModel.selectListRow(placemark)
                    }) {
                        SearchResultsListRowView(placemark: placemark)
                    }
                    .buttonStyle(SearchResultsListRowButtonStyle())
                }
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    SearchResultsView()
        .environmentObject(SearchViewModel(chooseMapMarker: { _ in }) { _ in })
}
