//
//  HomeSectionListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/2/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeSectionListRowView: View {
    var title: String
    var distance: Double
    var image: UIImage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(Color(BMColor.blackText))
                    .font(Font(BMFont.bold(18)))
                Spacer()
                distanceLabelView
            }
            .frame(height: 74)
            
            Spacer()
            imageView
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color(BMColor.modalBackground))
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.25), radius: 5)
    }
    
    private var distanceLabelView: some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundStyle(Color(BMColor.blackText))
                .font(.system(size: 16))
            
            Text("\(distance, specifier: "%.1f") mi")
                .foregroundStyle(Color(BMColor.blackText))
                .font(Font(BMFont.regular(16)))
        }
    }
    
    private var imageView: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    let defaultImage = UIImage(named: "DoeGlade")!
    HomeSectionListRowView(title: "Albany Bulb", distance: 8.4, image: defaultImage)
        .padding(40)
}
