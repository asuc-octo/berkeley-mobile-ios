//
//  SearchBarView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import MapKit
import SwiftUI

// MARK: - SearchBarView

struct SearchBarView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @FocusState private var isFocused: Bool
    
    private var onSearchBarTap: ((Bool) -> Void)?
    
    var body: some View {
        HStack {
            searchOrBackIcon
            
            TextField("What are you looking for?", text: $viewModel.searchText)
                .focused($isFocused)
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
            if viewModel.isSearchBarFocused != newValue {
                viewModel.isSearchBarFocused = newValue
            }
            onSearchBarTap?(newValue)
        }
        .onChange(of: viewModel.isSearchBarFocused) { newValue in
            if isFocused != newValue {
                isFocused = newValue
            }
        }
    }
    
    private var searchOrBackIcon: some View {
        Button(action: {
            if isFocused {
                viewModel.clearSearchText()
            }
            isFocused.toggle()
        }) {
            Image(systemName: isFocused ? "chevron.left" : "magnifyingglass")
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
                .frame(width: 20, alignment: .center)
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
