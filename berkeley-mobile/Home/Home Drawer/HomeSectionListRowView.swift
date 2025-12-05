//
//  HomeSectionListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/2/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeSectionListRowView: View {
    @Environment(HomeDrawerPinViewModel.self) private var homeDrawerPinViewModel
    
    var rowItem: any HomeDrawerSectionRowItemType
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rowItem.searchName)
                    .foregroundStyle(Color(BMColor.blackText))
                    .font(Font(BMFont.bold(18)))
                Spacer()
                HStack {
                    Group {
                        openClosedStatusView
                        distanceLabelView
                    }
                    .applyHomeDrawerRowAttributesStyle()
                }
            }
            .frame(height: 74)
            
            Spacer()
            
            imageView
        }
        .padding()
        .shadowfy()
    }
    
    @ViewBuilder
    private var openClosedStatusView: some View {
        if let itemWithOpenClosedStatus = rowItem as? (any HasOpenClosedStatus) {
            OpenClosedStatusView(status: itemWithOpenClosedStatus.isOpen ? .open : .closed)
        }
    }
    
    private var distanceLabelView: some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundStyle(Color(BMColor.blackText))
                .font(.system(size: 12))
            
            Text("\(rowItem.distanceToUser ?? 0.0, specifier: "%.1f") mi")
                .foregroundStyle(Color(BMColor.blackText))
                .font(Font(BMFont.light(12)))
        }
    }
    
    private var imageView: some View {
        BMCachedAsyncImageView(imageURL: rowItem.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill)
            .frame(maxWidth: 80, maxHeight: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                Group {
                    if homeDrawerPinViewModel.pinnedRowItemIDSet.contains(rowItem.docID) {
                        Image(systemName: "pin.circle.fill")
                            .foregroundStyle(.yellow)
                            .padding(4)
                    }
                },
                alignment: .topTrailing
            )
    }
}

#Preview {
    let foothillDiningHall = BMDiningHall(name: "Foothill", address: nil, phoneNumber: nil, imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FFoothill.jpg?alt=media&token=b645d675-6f51-45ea-99f7-9b36576e14b7", hours: [], latitude: 37.87538, longitude: -122.25612109999999)
    
    return HomeSectionListRowView(rowItem: foothillDiningHall)
        .padding(40)
}
