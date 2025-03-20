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
    let spacerHeight: CGFloat = 128 // Pushing some content visually to the center due to the top anchor of the SearchResultsView starting from the bottom of the SearchBarView
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                BMContentUnavailableView(iconName: "text.magnifyingglass", title: "Type Something", subtitle: "Search for anything you need.")
                Spacer()
                    .frame(height: spacerHeight)
                
            case .loading:
                // In UIKit we are using activityIndicator.startAnimating() - wasn't sure if we should keep it.
                ProgressView()
                Spacer()
                    .frame(height: spacerHeight)
                
            case .populated:
                populatedList
                
            case .empty:
                BMContentUnavailableView(iconName: "magnifyingglass", title: "Nothing found!", subtitle: "Try a different keyword.")
                Spacer()
                    .frame(height: spacerHeight)
                
            case .error(let error):
                BMContentUnavailableView(iconName: "exclamationmark.circle", title: "There is an Error", subtitle: error.localizedDescription)
                Spacer()
                    .frame(height: spacerHeight)
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
        }
    }
}

#Preview {
    SearchResultsView()
        .padding()
        .environmentObject(SearchViewModel(chooseMapMarker: { mapMarker in
            print("\(mapMarker)")
        }, choosePlacemark: { placemark in
            print("\(placemark)")
        }))
}
