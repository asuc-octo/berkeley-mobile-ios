//
//  AcademicEventRowView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct AcademicEventRowView: View {
    
    private struct Constants {
        static let cornerRadius: CGFloat = 8
        static let imageWidthHeight: CGFloat = 60
    }
    
    var event: BMEventCalendarEntry
    
    var body: some View {
        HStack {
            colorBarView
            eventInfoSection
            Spacer()
            BMCachedAsyncImageView(imageURL: event.imageURL, widthAndHeight: Constants.imageWidthHeight, cornerRadius: Constants.cornerRadius)
                .padding(.trailing, 10)
        }
        .overlay(
            BMAddedCalendarStatusOverlay(event: event)
        )
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .shadowfy()
    }
    
    private var colorBarView: some View {
        Color(event.color)
            .frame(width: 8)
    }
    
    private var eventInfoSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(event.name)
                .font(Font(BMFont.bold(12)))
            Text(event.dateString)
                .font(Font(BMFont.light(11)))
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}

#Preview {
    Group {
        AcademicEventRowView(event: BMEventCalendarEntry(name: "Seminar 231, Public Finance", date: Date()))
            .frame(width: 300)
        AcademicEventRowView(event: BMEventCalendarEntry(name: "Dissertation Talk: Toward Trustworthy Language Models: Interpretation Methods and Clinical Decision Support Applications", date: Date(), imageURL: "https://events.berkeley.edu/live/image/gid/84/width/200/height/200/crop/1/src_region/0,0,1080,1080/8428_NewEECSLogo-Livewhale.rev.1729531907.png"))
            .frame(width: 300)
    }
}
