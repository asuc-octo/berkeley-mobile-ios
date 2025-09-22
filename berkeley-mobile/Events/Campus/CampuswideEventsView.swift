//
//  CampuswideEventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/10/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CampuswideEventsView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var campuswideEventScrapper = EventScrapper(type: .campuswide)
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                CalendarEventsListView(scrapper: campuswideEventScrapper, proxy: proxy) { event in
                    CampusEventRowView(event: event)
                        .padding(.horizontal)
                        .background(
                            NavigationLink("") {
                                CampusEventDetailView(event: event)
                                    .environmentObject(eventsViewModel)
                            }
                            .opacity(0)
                        )
                }
                .environmentObject(calendarViewModel)
            }
        }
        .onAppear {
            campuswideEventScrapper.scrape()
            eventsViewModel.logCampuswideTabAnalytics()
        }
        .onChange(of: campuswideEventScrapper.alert) { alert in
            withoutAnimation {
                eventsViewModel.alert = alert
            }
        }
        .onChange(of: campuswideEventScrapper.groupedEntries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .refreshable {
            guard !campuswideEventScrapper.isLoading else {
                return
            }
            campuswideEventScrapper.scrape(forceRescrape: true)
        }
    }
}

#Preview {
    CampuswideEventsView()
        .background(Color(BMColor.cardBackground))
        .environmentObject(EventsViewModel())
}
