//
//  EventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GenericEventsView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var genericEventScrapper: EventScrapper
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    init(genericEventScrapper: EventScrapper) {
        _genericEventScrapper = StateObject(wrappedValue: genericEventScrapper)
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                CalendarEventsListView(scrapper: genericEventScrapper, proxy: proxy) { event in
                    EventRowView(event: event)
                        .padding(.horizontal)
                        .background(
                            NavigationLink("") {
                                EventDetailView(event: event)
                                    .environmentObject(eventsViewModel)
                            }
                            .opacity(0)
                        )
                }
                .environmentObject(calendarViewModel)
            }
        }
        .onAppear {
            genericEventScrapper.scrape()
            eventsViewModel.logCampuswideTabAnalytics()
        }
        .onChange(of: genericEventScrapper.alert) { alert in
            withoutAnimation {
                eventsViewModel.alert = alert
            }
        }
        .onChange(of: genericEventScrapper.groupedEntries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .refreshable {
            guard !genericEventScrapper.isLoading else {
                return
            }
            genericEventScrapper.scrape(forceRescrape: true)
        }
    }
}

struct EventsView: View {
    @StateObject private var eventsViewModel = EventsViewModel()
    
    @State private var tabSelectedIndex = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobTopRight", xOffset: 50, yOffset: -45, width: 300, height: 150)
                
                VStack {
                    BMSegmentedControlView(
                        tabNames: ["Academic", "Campus-Wide"],
                        selectedTabIndex: $tabSelectedIndex
                    )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    
                    TabView(selection: $tabSelectedIndex) {
                        GenericEventsView(genericEventScrapper: EventScrapper(type: .academic))
                            .environmentObject(eventsViewModel)
                            .tag(0)
                        GenericEventsView(genericEventScrapper: EventScrapper(type: .campuswide))
                            .environmentObject(eventsViewModel)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("Events")
            }
            .background(Color(BMColor.cardBackground))
        }
        .presentAlert(alert: $eventsViewModel.alert)
    }
}

#Preview {
    EventsView()
}
