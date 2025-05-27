//
//  CalendarEventsListView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/26/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CalendarEventsListView<Content:View>: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    let scrapper: EventScrapper
    let proxy: ScrollViewProxy
    @ViewBuilder var content: (BMEventCalendarEntry) -> Content
    
    var body: some View {
        List {
            Group {
                CalendarSectionView(scrollProxy: proxy) { day in
                    scrollToEvent(day: day, proxy: proxy)
                }
                .environmentObject(calendarViewModel)
               
                Group {
                    if scrapper.isLoading {
                        ProgressView()
                            .id(UUID())
                    } else {
                        if scrapper.groupedEntries.isEmpty {
                            BMNoEventsView()
                        } else {
                            Text("^[\(scrapper.allEntries.count) Event](inflect: true)")
                                .font(Font(BMFont.medium(16)))
                            
                            ForEach(Array(scrapper.groupedEntriesSortedKeys.enumerated()), id: \.offset) { index, date in
                                if let events = scrapper.groupedEntries[date] {
                                    EventsDateSectionView(date: date, events: events) { event in
                                        content(event)
                                    }
                                    .id(index)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color(BMColor.cardBackground))
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
        .listStyle(PlainListStyle())
    }
    
    private func scrollToEvent(day: Int, proxy: ScrollViewProxy) {
        guard let index = scrapper.groupedEntriesSortedKeys.map({ $0.get(.day)}).firstIndex(of: day) else {
            return
        }
        
        withAnimation {
            proxy.scrollTo(index, anchor: .top)
        }
    }
}

#Preview {
    let scrapper = EventScrapper(type: .academic)
    scrapper.scrape()
    
    return ScrollViewReader { proxy in
        CalendarEventsListView(scrapper: scrapper, proxy: proxy) { event in
            AcademicEventRowView(event: event)
                .frame(width: 310)
        }
        .environmentObject(EventsViewModel())
        .environmentObject(CalendarViewModel())
    }
}
