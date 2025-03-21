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
                Image(systemName: "clock.fill") 
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18) 
                    .foregroundColor(.gray)
                
                HStack {
                    if let isOpen = item.isOpen {
                        Text(isOpen ? "Open" : "Closed")
                            .font(.system(size: 12, weight: .medium)) 
                            .padding(.horizontal, 12) 
                            .padding(.vertical, 4) 
                            .background(isOpen ? .blue : .blue.opacity(0.7)) 
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .frame(width: 80, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    if let nextOpenInterval = item.nextOpenInterval() {
                        Text(formatTimeIntervalText(nextOpenInterval.dateInterval))
                            .foregroundColor(Color(.darkGray))
                            .font(.system(size: 12, weight: nextOpenInterval.dateInterval.contains(Date()) ? .bold : .regular))
                    } 
                }
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 12, weight: .medium)) 
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(isExpanded ? nil : .spring(response: 0.6, dampingFraction: 1.0), value: isExpanded)
                    .frame(width: 14)
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


// MARK: - Preview

struct OpenTimesCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OpenTimesCard(item: ClosedItem())
                .positionedAtTop()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Closed Item")
        
        OpenTimesCard(item: OpenItem())
            .positionedAtTop()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Open Item")
        }
    }
    
    // Open hour sample item 
    struct ClosedItem: HasOpenTimes {
        var weeklyHours: WeeklyHours? = createEmptyWeeklyHours()
        var isOpen: Bool? = false
        
        func nextOpenInterval() -> HoursInterval? {
            return nil
        }
        
        static func createEmptyWeeklyHours() -> WeeklyHours {
            let weeklyHours = WeeklyHours()
            return weeklyHours
        }
    }
    
    // Close hour sample item 
    struct OpenItem: HasOpenTimes {
        var weeklyHours: WeeklyHours? = createSampleWeeklyHours()
        var isOpen: Bool? = true
        
        func nextOpenInterval() -> HoursInterval? {
            guard let weeklyHours = weeklyHours else { return nil }
            let today = DayOfWeek.weekday(Date())
            let intervals = weeklyHours.hoursForWeekday(today)
            return intervals.first
        }
        
        static func createSampleWeeklyHours() -> WeeklyHours {
            let weeklyHours = WeeklyHours()
            
            func createHoursInterval(day: DayOfWeek, startHour: Int, startMinute: Int = 0, endHour: Int, endMinute: Int = 0) {
                let today = Date()
                let calendar = Calendar.current
                
                let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
                guard let baseDate = calendar.date(from: todayComponents) else { return }
                
                guard let startDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: baseDate),
                      let endDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: baseDate) else { return }
                
                let interval = HoursInterval(dateInterval: DateInterval(start: startDate, end: endDate))
                weeklyHours.addInterval(interval, to: day)
            }
            
            // Sample hours
            createHoursInterval(day: .monday, startHour: 9, endHour: 17)      // 9 AM - 5 PM
            createHoursInterval(day: .tuesday, startHour: 9, endHour: 17)     // 9 AM - 5 PM
            createHoursInterval(day: .wednesday, startHour: 9, endHour: 17)   // 9 AM - 5 PM
            createHoursInterval(day: .thursday, startHour: 9, endHour: 17)    // 9 AM - 5 PM
            createHoursInterval(day: .friday, startHour: 9, endHour: 16)      // 9 AM - 4 PM
            createHoursInterval(day: .saturday, startHour: 10, endHour: 14)   // 10 AM - 2 PM
            return weeklyHours
        }
    }
}
