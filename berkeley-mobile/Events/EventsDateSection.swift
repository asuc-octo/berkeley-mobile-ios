//
//  EventsDateSection.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct EventsDateSection<Content: View>: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    
    var date: Date
    var events: [BMEventCalendarEntry]
    @ViewBuilder var content: (BMEventCalendarEntry) -> Content
    
    var body: some View {
        Section(header: sectionDateText) {
            ForEach(events) { entry in
                content(entry)
            }
        }
    }
    
    private var sectionDateText: some View {
        HStack {
            Text(date.getDateString(withFormat: "EEEE, MMMM d"))
                .bold()
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}
