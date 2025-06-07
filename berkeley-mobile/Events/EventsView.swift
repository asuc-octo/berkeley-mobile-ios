//
//  EventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

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
                        AcademicCalendarView()
                            .environmentObject(eventsViewModel)
                            .tag(0)
                        CampuswideEventsView()
                            .environmentObject(eventsViewModel)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("Events")
            }
            .background(Color(BMColor.cardBackground))
        }
        .fullScreenCover(item: $eventsViewModel.alert) { alert in
            BMAlertView(alert: alert)
                .presentationBackground(Color.clear)
        }
    }
}

#Preview {
    EventsView()
}
