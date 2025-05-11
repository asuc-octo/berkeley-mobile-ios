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
                        BMCalendarView() { day in
                            scrollToEvent(day: day, proxy: scrollProxy)
                        }
                        .environmentObject(calendarViewModel)
                        calendarDivider
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
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
                academicEventScrapper.scrape()
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
            eventsViewModel.alert = alert
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
            } else {
                if academicEventScrapper.entries.isEmpty {
                    BMNoEventsView()
                } else {
                    ForEach(Array(academicEventScrapper.entries.enumerated()), id: \.offset) { index, entry in
                        HStack {
                            Spacer()
                            Button(action: {
                                eventsViewModel.showAddEventToCalendarAlert(entry)
                            }) {
                                AcademicEventRowView(event: entry, color: Color(entry.color))
                                    .frame(width: 310)
                                    .id(index)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func scrollToEvent(day: Int, proxy: ScrollViewProxy) {
        guard let index = calendarViewModel.entries.firstIndex(where: { $0.date.get(.day) == day }) else {
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
