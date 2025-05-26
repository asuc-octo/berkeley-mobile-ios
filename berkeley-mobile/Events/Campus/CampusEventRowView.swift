//
//  CampusEventRowView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CampusEventRowView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    var entry: BMEventCalendarEntry
    
    private let imageWidthAndHeight: CGFloat = 110
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(Font(BMFont.bold(15)))
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.dateString)
                        .fontWeight(.semibold)
                    Text(entry.location ?? "")
                }
                .fontWeight(.light)
            }
            .font(Font(BMFont.regular(11)))
            .frame(height: imageWidthAndHeight)
            
            Spacer()
            
            BMCachedAsyncImageView(imageURL: entry.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill, widthAndHeight: imageWidthAndHeight, cornerRadius: 12)
                .shadowfy()
                .overlay(
                    BMAddedCalendarStatusOverlay(event: entry)
                )
        }
        .padding()
        .shadowfy()
        .frame(height: 150)
    }
}

#Preview {
    return CampusEventRowView(entry: BMEventCalendarEntry.sampleEntry)
        .padding()
}
