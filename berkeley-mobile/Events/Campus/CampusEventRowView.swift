//
//  CampusEventRowView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CampusEventRowView: View {
    var entry: EventCalendarEntry
    
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
            
            BMCachedAsyncImageView(imageURL: entry.imageURL, placeholderImage: Constants.doeGladeImage, aspectRatio: .fill, widthAndHeight: imageWidthAndHeight, cornerRadius: 12)
                .shadowfy()
        }
        .padding()
        .shadowfy()
        .frame(height: 150)
    }
}

#Preview {
    let entry = EventCalendarEntry(name: "Exhibit: Amy Tan’s Backyard Birds", date: Date(), end: Date(), descriptionText: "The Backyard Bird Chronicles is a series of drawings by Amy Tan that contributed to her New York Times bestselling book of the same name. The resulting whimsical pictures capture the birds’ quirks, their personalities, their humor, and their dramas.", location: "The Bancroft Library Gallery", imageURL: "https://events.berkeley.edu/live/image/gid/139/width/200/height/200/crop/1/src_region/0,0,1535,2048/9842_Amytanimage.rev.1738954493.jpg", sourceLink: "https://events.berkeley.edu/events/event/290926-exhibit-amy-tans-backyard-birds")
    
    return CampusEventRowView(entry: entry)
        .padding()
}
