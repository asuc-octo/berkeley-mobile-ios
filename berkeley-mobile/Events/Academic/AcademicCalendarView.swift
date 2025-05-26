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
        ScrollViewReader { scrollProxy in
            List {
                Group {
                    VStack {
                        calendarDivider
                        CalendarView() { day in
                            scrollToEvent(day: day, proxy: scrollProxy)
                        }
                        .environmentObject(calendarViewModel)
                        calendarDivider
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    .buttonStyle(PlainButtonStyle())
                    
                    eventsListView
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color(BMColor.cardBackground))
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .listStyle(PlainListStyle())
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
        .onChange(of: academicEventScrapper.entries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .onChange(of: academicEventScrapper.alert) { alert in
            withoutAnimation {
                eventsViewModel.alert = alert
            }
        }
    }
    
    private var calendarDivider: some View {
        Divider()
            .background(Color(BMColor.gradientLightGrey))
    }
    
    @ViewBuilder
    private var eventsListView: some View {
        Group {
            if academicEventScrapper.isLoading {
                ProgressView()
                    .id(UUID())
            } else {
                if academicEventScrapper.entries.isEmpty {
                    BMNoEventsView()
                } else {
                    ForEach(Array(academicEventScrapper.groupedEntriesSortedKeys.enumerated()), id: \.offset) { index, date in
                        if let events = academicEventScrapper.entries[date] {
                            EventsDateSection(date: date, events: events) { entry in
                                Button(action: {
                                    eventsViewModel.showAddEventToCalendarAlert(entry)
                                }) {
                                    AcademicEventRowView(event: entry)
                                        .frame(width: 310)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .id(index)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func scrollToEvent(day: Int, proxy: ScrollViewProxy) {
        guard let index = academicEventScrapper.groupedEntriesSortedKeys.map({ $0.get(.day)}).firstIndex(of: day) else {
            return
        }
        
        withAnimation {
            proxy.scrollTo(index, anchor: .top)
        }
    }
}

#Preview {
    AcademicCalendarView()
        .background(Color(BMColor.cardBackground))
        .environmentObject(EventsViewModel())
}
