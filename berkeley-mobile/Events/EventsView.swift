//
//  EventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct EventsView: View {
    @InjectedObservable(\.eventsViewModel) private var eventsViewModel
    
    var body: some View {
        ZStack {
            BMTopBlobView(imageName: "BlobTopRight", xOffset: 50, yOffset: -45, width: 300, height: 150)
            NavigationStack {
                if eventsViewModel.eventsGroupedByDate.isEmpty {
                    BMNoEventsView()
                } else {
                    List(eventsViewModel.eventsGroupedByDate, id: \.0) { dayEvents in
                        EventsDateSectionView(date: dayEvents.0, events: dayEvents.1) { event in
                            if event.isAllDay == true {
                                AllDayEventBannerView(event: event)
                            } else {
                                EventRowView(event: event)
                                    .padding(.horizontal)
                                    .background(
                                        NavigationLink("") {
                                            EventDetailView(event: event)
                                                .presentAlert(alert: $eventsViewModel.alert)
                                        }
                                        .opacity(0)
                                    )
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                eventsViewModel.logCampuswideTabAnalytics()
            }
        }
        .navigationTitle("Events")
        .background(Color(BMColor.cardBackground))
    }
}

#Preview {
    EventsView()
}

struct AllDayEventBannerView: View {
    @InjectedObservable(\.eventsViewModel) private var eventsViewModel

    var event: BMEventCalendarEntry

    var body: some View {
        Capsule()
            .fill(.gray.opacity(0.5))
            .frame(height: 30)
            .overlay(
                HStack(spacing: 10) {
                    Text("All Day")
                        .font(Font(BMFont.bold(15)))
                    Text(event.name)
                        .font(Font(BMFont.regular(12)))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    NavigationLink("") {
                        EventDetailView(event: event)
                            .presentAlert(alert: $eventsViewModel.alert)
                    }
                    .opacity(0)
                )
            )
    }
}
