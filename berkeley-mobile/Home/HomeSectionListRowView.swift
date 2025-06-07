//
//  HomeSectionListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/2/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeSectionListRowView: View {
    var rowItem: SearchItem & HasLocation & HasImage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rowItem.searchName)
                    .foregroundStyle(Color(BMColor.blackText))
                    .font(Font(BMFont.bold(18)))
                Spacer()
                distanceLabelView
            }
            .frame(height: 74)
            
            Spacer()
            
            imageView
        }
        .padding()
        .shadowfy()
    }
    
    private var distanceLabelView: some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundStyle(Color(BMColor.blackText))
                .font(.system(size: 14))
            
            Text("\(rowItem.distanceToUser ?? 0.0, specifier: "%.1f") mi")
                .foregroundStyle(Color(BMColor.blackText))
                .font(Font(BMFont.light(14)))
        }
    }
    
    private var imageView: some View {
        BMCachedAsyncImageView(imageURL: rowItem.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill, widthAndHeight: 80, cornerRadius: 12)
    }
}

#Preview {
    let foothillDiningHall = DiningHall(name: "Foothill", address: nil, phoneNumber: nil, imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FFoothill.jpg?alt=media&token=b645d675-6f51-45ea-99f7-9b36576e14b7", shifts: MealMap(), hours: nil, latitude: 37.87538, longitude: -122.25612109999999)
    
    return HomeSectionListRowView(rowItem: foothillDiningHall)
        .padding(40)
}
