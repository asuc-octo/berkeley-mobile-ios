//
//  SearchBarView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @FocusState private var isFocused: Bool
    
    private var onSearchBarTap: ((Bool) -> Void)?
    
    var body: some View {
        HStack {
            searchOrBackIcon
            
            TextField("What are you looking for?", text: $viewModel.searchText)
                .focused($isFocused)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.searchLocations(viewModel.searchText)
                }
            
            if !viewModel.searchText.isEmpty {
                clearTextIcon
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 15))
        .shadow(color: .black.opacity(0.3), radius: 8)
        .onChange(of: isFocused) { newValue in // onChange syntax will need to change in later iOS
            switch viewModel.state {
            case .populated,
                    .idle where (!viewModel.recentSearches.isEmpty && viewModel.isSearching):
                /*
                 .scrollDismissesKeyboard(.immediately) in SearchResultsView
                 triggers FocusState change by default.
                 To keep searching state active when we want to scroll through
                 the list of search items (case = .populated) or recent search
                 items (.idle + !viewModel.recentSearch.isEmpty) we pass through
                 this FocusState change.
                 viewModel.isSearching condition is needed for scenario when
                 searchBar is initally tapped from the HomeView.
                */
                break
            default:
                viewModel.isSearching = newValue
            }
        }
        .onChange(of: viewModel.isSearching) { newValue in
            isFocused = newValue
            onSearchBarTap?(newValue)
        }
    }
    
    private var searchOrBackIcon: some View {
        Button(action: {
            if viewModel.isSearching {
                viewModel.clearSearchText()
            }
            viewModel.isSearching.toggle()
        }) {
            Image(systemName: viewModel.isSearching ? "chevron.left" : "magnifyingglass")
                .foregroundStyle(Color(BMColor.searchBarIconColor))
                .fontWeight(.semibold)
                .frame(width: 20, alignment: .center) // So that changing an icon didn't move the TextField
        }
    }
    
    private var clearTextIcon: some View {
        Button(action: {
            viewModel.clearSearchText()
        }) {
            Image(systemName: "xmark")
                .foregroundStyle(Color(BMColor.searchBarIconColor))
                .fontWeight(.semibold)
                .frame(width: 30, alignment: .center)
        }
    }
    
    init(onSearchBarTap: ((Bool) -> Void)? = nil) {
        self.onSearchBarTap = onSearchBarTap
    }
}

#Preview {
    SearchBarView()
        .padding()
        .ignoresSafeArea()
        .environmentObject(SearchViewModel(chooseMapMarker: { _ in }) { _ in })
}
