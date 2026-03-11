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
    @StateObject private var eventsDataSource: EventsDataSource
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    init(eventsDataSource: EventsDataSource) {
        _eventsDataSource = StateObject(wrappedValue: eventsDataSource)
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                CalendarEventsListView(dataSource: eventsDataSource, proxy: proxy) { event in
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
            eventsDataSource.scrape()
            eventsViewModel.logCampuswideTabAnalytics()
        }
        .onChange(of: eventsDataSource.alert) { alert in
            withoutAnimation {
                eventsViewModel.alert = alert
            }
        }
        .onChange(of: eventsDataSource.groupedEntries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .refreshable {
            guard !eventsDataSource.isLoading else {
                return
            }
            eventsDataSource.scrape(forceRescrape: true)
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
                        GenericEventsView(eventsDataSource: EventsDataSource(type: .academic))
                            .environmentObject(eventsViewModel)
                            .tag(0)
                        GenericEventsView(eventsDataSource: EventsDataSource(type: .campuswide))
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
