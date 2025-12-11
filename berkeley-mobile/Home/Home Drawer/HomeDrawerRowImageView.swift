//
//  HomeDrawerRowImageView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/10/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeDrawerRowImageView: View {
    @Environment(HomeDrawerPinViewModel.self) private var homeDrawerPinViewModel
    
    var item: any HomeDrawerSectionRowItemType
    
    var body: some View {
        BMCachedAsyncImageView(imageURL: item.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                Group {
                    if homeDrawerPinViewModel.pinnedRowItemIDSet.contains(item.docID) {
                        Image(systemName: "pin.circle.fill")
                            .foregroundStyle(.yellow)
                            .padding(4)
                    }
                },
                alignment: .topTrailing
            )
    }
}
