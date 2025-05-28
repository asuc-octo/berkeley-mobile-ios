//
//  EventsDateSectionView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct EventsDateSectionView<Content: View>: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
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
                .bold()
                .addBadgeStyle(widthAndHeight: 25)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let eventsViewModel = EventsViewModel()
    Group {
        EventsDateSectionView(date: Date(), events: [BMEventCalendarEntry.sampleEntry]) { event in
            CampusEventRowView(event: event)
                .frame(width: 310)
                .background(
                    NavigationLink("") {
                        CampusEventDetailView(event: event)
                    }
                    .opacity(0)
                )
        }
        
        EventsDateSectionView(date: Date(), events: [BMEventCalendarEntry.sampleEntry]) { event in
            AcademicEventRowView(event: event)
                .frame(width: 310)
        }
    }
    .environmentObject(eventsViewModel)
}
