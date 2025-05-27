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
                List {
                    Group {
                        if campuswideEventScrapper.isLoading {
                            ProgressView()
                                .id(UUID())
                        } else if campuswideEventScrapper.entries.isEmpty {
                            BMNoEventsView()
                        } else {
                            Group {
                                CalendarSectionView(scrollProxy: proxy) { day in
                                    scrollToEvent(day: day, proxy: proxy)
                                }
                                .environmentObject(calendarViewModel)
                                eventsListView
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(BMColor.cardBackground))
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
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
        .onChange(of: campuswideEventScrapper.entries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .refreshable {
            guard !campuswideEventScrapper.isLoading else {
                return
            }
            campuswideEventScrapper.scrape(forceRescrape: true)
        }
    }
    
    private var eventsListView: some View {
        ForEach(Array(campuswideEventScrapper.groupedEntriesSortedKeys.enumerated()), id: \.offset) { index,  date in
            if let events = campuswideEventScrapper.entries[date] {
                EventsDateSectionView(date: date, events: events) { event in
                    CampusEventRowView(event: event)
                        .frame(width: 310)
                        .background(
                            NavigationLink("") {
                                CampusEventDetailView(event: event)
                                    .environmentObject(eventsViewModel)
                            }
                            .opacity(0)
                        )
                }
                .id(index)
            }
        }
    }
    
    private func scrollToEvent(day: Int, proxy: ScrollViewProxy) {
        guard let index = campuswideEventScrapper.groupedEntriesSortedKeys.map({ $0.get(.day)}).firstIndex(of: day) else {
            return
        }
        
        withAnimation {
            proxy.scrollTo(index, anchor: .top)
        }
    }
}

#Preview {
    CampuswideEventsView()
        .background(Color(BMColor.cardBackground))
        .environmentObject(EventsViewModel())
}
