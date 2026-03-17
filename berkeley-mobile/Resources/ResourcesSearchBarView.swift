//
//  ResourcesSearchBarView.swift
//  berkeley-mobile
//
//  Created with reference to SearchBarView.swift
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct ResourcesSearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(BMColor.searchBarIconColor))
                    .fontWeight(.semibold)
                    .frame(width: 20, alignment: .center)

                TextField("What are you looking for?", text: $searchText)
                    .focused($isFocused)
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color(BMColor.searchBarIconColor))
                            .fontWeight(.semibold)
                            .frame(width: 30, alignment: .center)
                    }
                }
            }
            .padding()
            .modify {
                if #available(iOS 26.0, *) {
                    $0.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
                } else {
                    $0.background(.regularMaterial)
                }
            }
            .clipShape(.rect(cornerRadius: 15))
            .shadow(color: .black.opacity(0.3), radius: 8)

            if isSearching {
                Button("Cancel") {
                    searchText = ""
                    isSearching = false
                }
                .foregroundStyle(Color(BMColor.barGraphEntryCurrent))
                .font(Font(BMFont.medium(16)))
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSearching)
        .onChange(of: isFocused) { _, newValue in
            if newValue {
                isSearching = true
            }
        }
        .onChange(of: isSearching) { _, newValue in
            isFocused = newValue
        }
    }
}
