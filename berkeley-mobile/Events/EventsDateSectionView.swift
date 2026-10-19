//
//  EventsDateSectionView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct EventsDateSectionView<Content: View>: View {
    @InjectedObservable(\.eventsViewModel) private var eventsViewModel

    var date: Date
    var events: [BMEventCalendarEntry]
    @ViewBuilder var content: (BMEventCalendarEntry) -> Content
    
    var body: some View {
        Section(header: sectionHeader) {
            ForEach(events) { event in
                content(event)
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(date.getDateString(withFormat: "EEEE, MMMM d"))
                .bold()
                .font(.headline)
            Spacer()
            Text("\(events.count)")
                .font(Font(BMFont.bold(15)))
                .addBadgeStyle(widthAndHeight: 30, isInteractive: false)
        }
        .padding()
    }
}

#Preview {
    Group {
        EventsDateSectionView(date: Date(), events: [BMEventCalendarEntry.sampleEntry]) { event in
            EventRowView(event: event)
                .frame(width: 310)
                .background(
                    NavigationLink("") {
                        EventDetailView(event: event)
                    }
                    .opacity(0)
                )
        }
        
        EventsDateSectionView(date: Date(), events: [BMEventCalendarEntry.sampleEntry]) { event in
            EventRowView(event: event)
                .frame(width: 310)
        }
    }
}
