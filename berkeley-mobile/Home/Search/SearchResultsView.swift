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
    // top padding: 128 = SearchBarTopMargin (74) + SearchBarHeight (54)
    private let listPadding = EdgeInsets(top: 128, leading: 21, bottom: 96, trailing: 21)
    
    var body: some View {
        ZStack {
            // Masking view behind, when search is active:
            VStack{}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            
            VStack {
                switch viewModel.state {
                case .idle:
                    if viewModel.recentSearches.isEmpty {
                        BMContentUnavailableView(iconName: "text.magnifyingglass", title: "Type Something", subtitle: "Search for anything you need.")
                    } else {
                        recentSearchesList
                            .padding(listPadding)
                    }
                case .loading:
                    ProgressView()
                    
                case .populated:
                    populatedList
                        .padding(listPadding)
                    
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
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var recentSearchesList: some View {
        VStack {
            HStack {
                Text("Recents")
                    .font(Font(BMFont.regular(14)))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.snappy) {
                        viewModel.deleteAllRecentSearch()
                    }
                }) {
                    Text("Clear all")
                        .font(Font(BMFont.regular(14)))
                }
            }
            .padding(.top, 16)
            
            List {
                ForEach(viewModel.recentSearches, id: \.self) { codablePlacemark in
                    Button(action: {
                        guard let placemark = MapPlacemark.fromCodable(codablePlacemark) else {
                            return
                        }
                        viewModel.selectListRow(placemark)
                    }) {
                        RecentSearchListRowView(codablePlacemark: codablePlacemark)
                    }
                    .buttonStyle(SearchResultsListRowButtonStyle())
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: viewModel.deleteRecentSearchItem)
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

#Preview {
    SearchResultsView()
        .environmentObject(SearchViewModel(chooseMapMarker: { _ in }) { _ in })
}

