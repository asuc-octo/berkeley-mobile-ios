//
//  CampuswideEventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/10/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CampusEventDetailView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CampusEventDetailViewController
    
    var entry: EventCalendarEntry

    func makeUIViewController(context: Context) -> CampusEventDetailViewController {
        let detailVC = CampusEventDetailViewController()
        detailVC.event = entry
        return detailVC
    }

    func updateUIViewController(_ uiViewController: CampusEventDetailViewController, context: Context) {}
}

struct CampuswideEventsView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @StateObject private var campuswideEventScrapper = EventScrapper(type: .campuswide)
    
    @State private var selectedEntry: EventCalendarEntry?
    
    var body: some View {
        List {
            Group {
                if campuswideEventScrapper.isLoading {
                    ProgressView()
                        .id(UUID())
                } else if campuswideEventScrapper.entries.isEmpty {
                    BMNoEventsView()
                } else {
                    ForEach(Array(campuswideEventScrapper.entries.enumerated()), id: \.offset) { index, entry in
                        Button(action: {
                            selectedEntry = entry
                        }) {
                            CampusEventRowView(entry: entry)
                                .frame(width: 310)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
            .listRowBackground(Color(BMColor.cardBackground))
        }
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
        .onAppear {
            campuswideEventScrapper.scrape()
            eventsViewModel.logCampuswideTabAnalytics()
        }
        .onChange(of: campuswideEventScrapper.alert) { alert in
            eventsViewModel.alert = alert
        }
        .sheet(item: $selectedEntry) { entry in
            CampusEventDetailView(entry: entry)
                .ignoresSafeArea()
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
