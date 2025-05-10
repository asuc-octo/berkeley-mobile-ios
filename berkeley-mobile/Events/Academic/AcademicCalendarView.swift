//
//  AcademicCalendarView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct AcademicCalendarView: View {
    @StateObject private var academicCalendarViewModel = AcademicCalendarViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical) {
                VStack {
                    calendarDivider
                    BMCalendarView() { day in
                        scrollToEvent(day: day, proxy: scrollProxy)
                    }
                    .environmentObject(calendarViewModel)
                    calendarDivider
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                eventsListView
            }
            .scrollIndicators(.visible)
        }
        .onAppear {
            academicCalendarViewModel.logAcademicCalendarTabAnalytics()
            academicCalendarViewModel.scrapeAcademicEvents()
        }
        .onChange(of: academicCalendarViewModel.entries) { entries in
            calendarViewModel.setEntries(entries)
        }
        .fullScreenCover(item: $academicCalendarViewModel.alert) { alert in
            BMAlertView(alert: alert)
                .presentationBackground(Color.clear)
        }
    }
    
    private var calendarDivider: some View {
        Divider()
            .background(Color(BMColor.gradientLightGrey))
    }
    
    @ViewBuilder
    private var eventsListView: some View {
        if academicCalendarViewModel.isLoading {
            ProgressView()
        } else {
            if academicCalendarViewModel.entries.isEmpty {
                noEventsView
            } else {
                LazyVStack {
                    ForEach(Array(academicCalendarViewModel.entries.enumerated()), id: \.offset) { index, entry in
                        Button(action: {
                            academicCalendarViewModel.showAddEventToCalendarAlert(entry)
                        }) {
                            AcademicEventRowView(event: entry, color: Color(entry.color))
                                .frame(width: 310)
                                .id(index)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private var noEventsView: some View {
        VStack {
            Spacer()
            BMContentUnavailableView(iconName: "", title: "No Events Available", subtitle: "Please try again.")
            Spacer()
        }
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
}
