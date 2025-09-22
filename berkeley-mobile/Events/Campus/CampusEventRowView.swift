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
    
    var event: BMEventCalendarEntry
    
    private let imageWidthAndHeight: CGFloat = 110
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(Font(BMFont.bold(15)))
                    .padding(.top, 7.5)
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.dateString)
                        .fontWeight(.semibold)
                    Text(event.location ?? "")
                }
                .fontWeight(.light)
            }
            .font(Font(BMFont.regular(11)))
            .frame(height: imageWidthAndHeight)
            
            Spacer()
            
            BMCachedAsyncImageView(imageURL: event.imageURL, placeholderImage: BMConstants.doeGladeImage, aspectRatio: .fill, widthAndHeight: imageWidthAndHeight, cornerRadius: 12)
                .shadowfy()
                .overlay(
                    BMAddedCalendarStatusOverlayView(event: event)
                )
        }
        .padding()
        .shadowfy()
        .frame(height: 150)
        .addEventsContextMenu(event: event)
    }
}

#Preview {
    CampusEventRowView(event: BMEventCalendarEntry.sampleEntry)
        .padding()
}
