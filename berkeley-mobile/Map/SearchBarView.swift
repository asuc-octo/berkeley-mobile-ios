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
            leftIcon
            
            TextField("What are you looking for?", text: $viewModel.searchText)
                .focused($isFocused)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.searchLocations(viewModel.searchText)
                }
            
            if !viewModel.searchText.isEmpty {
                rightIcon
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
            
            if newValue == true {
                onSearchBarTap?(true)
            } else {
                onSearchBarTap?(false)
            }
        }
        .onChange(of: viewModel.isSearchBarFocused) { newValue in
            if isFocused != newValue {
                isFocused = newValue
            }
        }
    }
    
    private var leftIcon: some View {
        Button(action: {
            if isFocused {
                isFocused = false
                viewModel.clearSearchText()
            } else {
                isFocused = true
            }
        }) {
            Image(systemName: isFocused ? "chevron.left" : "magnifyingglass")
                .foregroundStyle(Color(BMColor.searchBarIconColor))
                .fontWeight(.semibold)
                .frame(width: 20, alignment: .center) // So that changing an icon didn't move the TextField
        }
    }
    
    private var rightIcon: some View {
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
        .environmentObject(SearchViewModel(chooseMapMarker: { mapMarker in
            print("\(mapMarker)")
        }, choosePlacemark: { placemark in
            print("\(placemark)")
        }))
}
