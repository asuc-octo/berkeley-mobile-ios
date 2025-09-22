//
//  AcademicCalendarView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct AcademicCalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var academicEventScrapper = EventScrapper(type: .academic)
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        ScrollViewReader { proxy in
            CalendarEventsListView(scrapper: academicEventScrapper, proxy: proxy) { event in
                    CampusEventRowView(event: event)
                        .padding(.horizontal)
                        .background(
                            NavigationLink("") {
                                CampusEventDetailView(event: event)
                                    .environmentObject(eventsViewModel)
                            }
                            .opacity(0)
                        )
                
                .buttonStyle(PlainButtonStyle())
            }
            .environmentObject(calendarViewModel)
            .refreshable {
                guard !academicEventScrapper.isLoading else {
                    return
                }
                academicEventScrapper.scrape(forceRescrape: true)
            }
        }
        .onAppear {
            academicEventScrapper.scrape()
            eventsViewModel.logAcademicCalendarTabAnalytics()
        }
        .onChange(of: academicEventScrapper.groupedEntries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .onChange(of: academicEventScrapper.alert) { alert in
            withoutAnimation {
                eventsViewModel.alert = alert
            }
        }
    }
}

#Preview {
    AcademicCalendarView()
        .background(Color(BMColor.cardBackground))
        .environmentObject(EventsViewModel())
}
