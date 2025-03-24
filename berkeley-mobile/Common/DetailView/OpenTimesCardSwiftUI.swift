//
//  OpenTimesCardSwiftUI.swift
//      
//  Created by Yihang Chen on 3/13/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct OpenTimesCard: View {
    @State private var isExpanded = false

    let item: HasOpenTimes
    
    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        VStack {
            headerView()
                .background(Color(BMColor.cardBackground))
                .zIndex(1) 
            
            if isExpanded {
                expandableContentView()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color(BMColor.cardBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .animation(.spring(response: 0.4, dampingFraction: 1.0), value: isExpanded)
        .padding(.bottom, 8) 
        .zIndex(100)
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        Button(action: {
            toggleWithAnimation()
        }) {
            HStack(spacing: 12) { 
                clockIcon
                
                HStack {
                    statusBadge
                    
                    Spacer()
                    
                    openTimeText
                }
                
                chevronIcon
            }
            .contentShape(Rectangle()) 
            .padding(.horizontal, 14) 
            .padding(.vertical, 10) 
        }
        .buttonStyle(PlainButtonStyle())
        
        if isExpanded {
            Divider()
        }
    }
    
    private var clockIcon: some View {
        Image(systemName: "clock") 
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18) 
    }
    
    private var statusBadge: some View {
        Group {
            if let isOpen = item.isOpen {
                Text(isOpen ? "Open" : "Closed")
                    .font(.system(size: 12, weight: .medium)) 
                    .padding(.horizontal, 12) 
                    .padding(.vertical, 4) 
                    .background(isOpen ? Color.green : Color.red) 
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .frame(width: 80, alignment: .leading)
            }
        }
    }
    
    private var openTimeText: some View {
        Group {
            if let nextOpenInterval = item.nextOpenInterval() {
                Text(formatTimeIntervalText(nextOpenInterval.dateInterval))
                    .foregroundColor(Color(.darkGray))
                    .font(.system(size: 12, weight: nextOpenInterval.dateInterval.contains(Date()) ? .bold : .regular))
            }
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .medium)) 
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .animation(isExpanded ? nil : .spring(response: 0.6, dampingFraction: 1.0), value: isExpanded)
            .frame(width: 14)
    }
    
    @ViewBuilder
    private func expandableContentView() -> some View {
        VStack(spacing: 2) { 
            ForEach(0..<dayNames.count, id: \.self) { index in
                let day = dayNames[index]
                let dayOfWeek = DayOfWeek.allCases[index]
                let isCurrentDay = index == Date().weekday()
                
                HStack {
                    Text(day)
                        .foregroundColor(.black)
                        .padding(.leading, 55)
                    
                    Spacer()
                    
                    Text(hoursText(for: dayOfWeek, isCurrentDay: isCurrentDay))
                        .foregroundColor(Color(.darkGray))
                        .padding(.trailing, 26)
                }
                .font(.system(size: 12, weight: isCurrentDay ? .bold : .regular))
                .lineSpacing(0)
                .frame(height: 22) 
                .contentShape(Rectangle())
                .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .background(Color(BMColor.cardBackground))
    }
    
    private func toggleWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 1.0)) {
            isExpanded.toggle()
        }
    }
    
    private func hoursText(for day: DayOfWeek, isCurrentDay: Bool) -> String {
        guard let weeklyHours = item.weeklyHours else {
            return "Closed"
        }
        
        let intervals = weeklyHours.hoursForWeekday(day)
        
        guard !intervals.isEmpty, 
              !intervals.allSatisfy({ $0.dateInterval.duration <= 0 }),
              let interval = intervals.first,
              let start = interval.dateInterval.start.timeOnly(),
              let end = interval.dateInterval.end.timeOnly() else {
            return "Closed"
        }
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: start, to: end)
    }
    
    private func formatTimeIntervalText(_ interval: DateInterval) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        guard let start = interval.start.timeOnly(),
              let end = interval.end.timeOnly() else {
            return ""
        }
        
        return formatter.string(from: start, to: end)
    }
}

    struct ClosedItem: HasOpenTimes {
        var weeklyHours: WeeklyHours? = createEmptyWeeklyHours()
        
        func nextOpenInterval() -> HoursInterval? {
            return nil
        }
        
        static func createEmptyWeeklyHours() -> WeeklyHours {
            let weeklyHours = WeeklyHours()
            return weeklyHours
        }
    }
    
    struct OpenItem: HasOpenTimes {
        var weeklyHours: WeeklyHours? = createSampleWeeklyHours()
        
        func nextOpenInterval() -> HoursInterval? {
            guard let weeklyHours = weeklyHours else {
                return nil
            }
            let today = DayOfWeek.weekday(Date())
            let intervals = weeklyHours.hoursForWeekday(today)
            return intervals.first
        }
        
        static func createSampleWeeklyHours() -> WeeklyHours {
            let weeklyHours = WeeklyHours()
            
            func createHoursInterval(day: DayOfWeek, startHour: Int, startMinute: Int = 0, endHour: Int, endMinute: Int = 0) {
                let today = Date()
                
                let startDate = Date.getTodayShiftDate(for: today, hourComponent: startHour, minuteComponent: startMinute, secondComponent: 0)
                let endDate = Date.getTodayShiftDate(for: today, hourComponent: endHour, minuteComponent: endMinute, secondComponent: 0)
                
                let interval = HoursInterval(dateInterval: DateInterval(start: startDate, end: endDate))
                weeklyHours.addInterval(interval, to: day)
            }
            
            // Sample hours
            createHoursInterval(day: .monday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .tuesday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .wednesday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .thursday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .friday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .saturday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            createHoursInterval(day: .sunday, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
            return weeklyHours
        }
    }


// MARK: - Previews

#Preview("Closed Item Card") {
    OpenTimesCard(item: ClosedItem())
        .positionedAtTop()
}
 
#Preview("Open Item Card") {
    OpenTimesCard(item: OpenItem())
        .positionedAtTop()
}


