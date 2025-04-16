//
//  GymOccupancyWidget.swift
//  GymOccupancyWidget
//
//  Created by Justin Wong on 4/13/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI
import WidgetKit

typealias GymOccupancyChange = (prior: Double?, current: Double)

struct GymOccupancyEntry: TimelineEntry {
    static let defaultRSFOccupancyPercentages: GymOccupancyChange = (100, 91)
    static let defaultStadiumOccupancyPercentages: GymOccupancyChange = (43, 68)
    
    let date: Date
    let RSFOccupancyPercentages: GymOccupancyChange
    let stadiumOccupancyPercentages: GymOccupancyChange
}

class GymOccupancyEntryCache {
    var entry: GymOccupancyEntry?
}


// MARK: - GymOccupancyProvider

struct GymOccupancyProvider: TimelineProvider {
    private let rsfGymOccupancyViewModel = GymOccupancyViewModel(location: .rsf)
    private let stadiumGymOccupancyViewModel = GymOccupancyViewModel(location: .stadium)
    private let entryCache = GymOccupancyEntryCache()
    
    private var priorRSFOccupancy: Double?  {
        entryCache.entry?.RSFOccupancyPercentages.current
    }
    private var priorStadiumOccupancy: Double? {
        entryCache.entry?.stadiumOccupancyPercentages.current
    }
    
    func placeholder(in context: Context) -> GymOccupancyEntry {
        GymOccupancyEntry(
            date: Date(),
            RSFOccupancyPercentages: GymOccupancyEntry.defaultRSFOccupancyPercentages,
            stadiumOccupancyPercentages: GymOccupancyEntry.defaultStadiumOccupancyPercentages
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GymOccupancyEntry) -> ()) {
        let areOccupancyPercentagesUnavailable = rsfGymOccupancyViewModel.occupancyPercentage == nil && stadiumGymOccupancyViewModel.occupancyPercentage == nil
        
        if context.isPreview && areOccupancyPercentagesUnavailable {
            let entry = GymOccupancyEntry(
                date: Date(),
                RSFOccupancyPercentages: GymOccupancyEntry.defaultRSFOccupancyPercentages,
                stadiumOccupancyPercentages: GymOccupancyEntry.defaultStadiumOccupancyPercentages
            )
            completion(entry)
        } else {
            let entry = GymOccupancyEntry(date: Date(),
                                          RSFOccupancyPercentages: (priorRSFOccupancy, rsfGymOccupancyViewModel.occupancyPercentage ?? 0),
                                          stadiumOccupancyPercentages: ( priorStadiumOccupancy,stadiumGymOccupancyViewModel.occupancyPercentage ?? 0))
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchGymOccupancies { currRSFOccupancy, currStadiumOccupancy in
            let entry = GymOccupancyEntry(
                date: Date(),
                RSFOccupancyPercentages: (priorRSFOccupancy, currRSFOccupancy),
                stadiumOccupancyPercentages: (priorStadiumOccupancy, currStadiumOccupancy)
            )
            
            entryCache.entry = entry
            
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchGymOccupancies(completion: @escaping (Double, Double) -> Void) {
        rsfGymOccupancyViewModel.refreshWithCompletionHandler { RSFOccupancy in
            stadiumGymOccupancyViewModel.refreshWithCompletionHandler { stadiumOccupancy in
               completion(RSFOccupancy ?? 0, stadiumOccupancy ?? 0)
            }
        }
    }
}


// MARK: - GymOccupancyWidgetEntryView

struct GymOccupancyWidgetEntryView : View {
    var entry: GymOccupancyProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            GymOccupancyWidgetRowView(location: .rsf, entry: entry)
            Spacer()
            GymOccupancyWidgetRowView(location: .stadium, entry: entry)
            Spacer()
            relativeDateText
            Spacer()
        }
        .padding(.leading)
    }
    
    private var relativeDateText: some View {
        Text("\(Text(entry.date, style: .relative)) ago")
            .font(Font(BMFont.regular(10)))
            .fontWeight(.medium)
    }
}


// MARK: - GymOccupancyWidgetRowView

struct GymOccupancyWidgetRowView: View {
    var location: GymOccupancyLocation
    var entry: GymOccupancyEntry
    
    private var occupancyColor: Color {
        switch location {
        case .rsf:
            GymOccupancyViewModel.getOccupancyColor(percentage: entry.RSFOccupancyPercentages.current)
        case .stadium:
            GymOccupancyViewModel.getOccupancyColor(percentage: entry.stadiumOccupancyPercentages.current)
        }
    }
    
    private var occupancyPercentage: Double {
        switch location {
        case .rsf:
            return entry.RSFOccupancyPercentages.current
        case .stadium:
            return entry.stadiumOccupancyPercentages.current
        }
    }
    
    private var percentageDiff: Double {
        switch location {
        case .rsf:
            return entry.RSFOccupancyPercentages.current - (entry.RSFOccupancyPercentages.prior ?? 0.0)
        case .stadium:
            return entry.stadiumOccupancyPercentages.current - (entry.stadiumOccupancyPercentages.prior ?? 0.0)
        }
    }
    
    var body: some View {
        Text(location.rawValue)
            .font(Font(BMFont.regular(13)))
            .bold()
        HStack {
            increaseDecreaseIndicator
            occupancyPercentageText
        }
    }
    
    private var increaseDecreaseIndicator: some View {
        Image(systemName: percentageDiff == 0 ? "equal.circle.fill" : "triangle.fill")
            .rotationEffect(percentageDiff >= 0 ? .degrees(0) : .degrees(180))
            .foregroundStyle(percentageDiff > 0 ? .red : .green)
            .font(.system(size: 16))
            .frame(width: 20)
    }
    
    private var occupancyPercentageText: some View {
        Text("\(Int(occupancyPercentage))")
            .foregroundStyle(occupancyColor)
            .contentTransition(.numericText(value: occupancyPercentage))
            .font(.system(size: 30))
            .fontWeight(.semibold)
    }
}


// MARK: - GymOccupancyWidget

struct GymOccupancyWidget: Widget {
    let kind: String = "GymOccupancyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GymOccupancyProvider()) { entry in
            if #available(iOS 17.0, *) {
                GymOccupancyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                GymOccupancyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Gym Occupancy")
        .description("View the current RSF Weight Rooms and CMS Fitness Center occupancies.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    GymOccupancyWidget()
} timeline: {
    GymOccupancyEntry(date: .now, RSFOccupancyPercentages: (71, 93), stadiumOccupancyPercentages: (68, 40))
    GymOccupancyEntry(date: .now, RSFOccupancyPercentages: (93, 74), stadiumOccupancyPercentages: (40, 43))
    GymOccupancyEntry(date: .now, RSFOccupancyPercentages: (74, 74), stadiumOccupancyPercentages: (43, 40))
    GymOccupancyEntry(date: .now, RSFOccupancyPercentages: (74, 108), stadiumOccupancyPercentages: (40, 9))
}
