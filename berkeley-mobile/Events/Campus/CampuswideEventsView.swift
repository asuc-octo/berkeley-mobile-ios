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
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    if campuswideEventScrapper.isLoading {
                        ProgressView()
                            .id(UUID())
                    } else if campuswideEventScrapper.entries.isEmpty {
                        BMNoEventsView()
                    } else {
                        ForEach(campuswideEventScrapper.entries.keys.sorted(), id: \.self) { date in
                            if let events = campuswideEventScrapper.entries[date] {
                                EventsDateSection(date: date, events: events) { entry in
                                    CampusEventRowView(entry: entry)
                                        .frame(width: 310)
                                        .background(
                                            NavigationLink("") {
                                                CampusEventDetailView(event: entry)
                                                    .environmentObject(eventsViewModel)
                                            }
                                            .opacity(0)
                                        )
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowBackground(Color(BMColor.cardBackground))
            }
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
        }
        .onAppear {
            campuswideEventScrapper.scrape()
            eventsViewModel.logCampuswideTabAnalytics()
        }
        .onChange(of: campuswideEventScrapper.alert) { alert in
            eventsViewModel.alert = alert
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
