//
//  BMContentUnavailableView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMContentUnavailableView: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundStyle(Color(BMColor.searchBarIconColor))
                .padding(.bottom, 16)
            
            Text(title)
                .font(Font(BMFont.bold(17)))
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(Font(BMFont.regular(17)))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding([.horizontal], 50)
        }
    }
}

#Preview {
    BMContentUnavailableView(iconName: "magnifyingglass", title: "No Results", subtitle: "You haven't searched yet")
}
