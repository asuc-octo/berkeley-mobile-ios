//
//  OpenTimesCardSwiftUI.swift
//      
//  Created by Yihang Chen on 3/13/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

class SizeReporter: ObservableObject {
    @Published var size: CGSize = .zero
    var onSizeChange: ((CGSize) -> Void)?
    
    func updateSize(_ newSize: CGSize) {
        if newSize != size {
            size = newSize
            onSizeChange?(newSize)
        }
    }
}

struct OpenTimesCard: View {
    let item: HasOpenTimes
    @State private var isExpanded: Bool = false
    @EnvironmentObject private var sizeReporter: SizeReporter
    
    private var currentDayOfWeek: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }
    
    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                headerView()
                    .background(Color.white)
                    .frame(width: geometry.size.width)
                
                if isExpanded {
                    expandableContentView()
                        .transition(.opacity) 
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1) 
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                        .onAppear {
                            sizeReporter.updateSize(geometry.size)
                        }
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                if isExpanded {
                    withAnimation(.spring(response: 0.6, dampingFraction: 1.0)) {
                        sizeReporter.updateSize(newSize)
                    }
                } else {
                    sizeReporter.updateSize(newSize)
                }
            }
        }
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        Button(action: {
            toggleWithAnimation()
        }) {
            HStack(spacing: 12) { 
                Image("Clock") 
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18) 
                    .foregroundColor(Color.gray)
                
                HStack {
                    if let isOpen = item.isOpen {
                        Text(isOpen ? "Open" : "Closed")
                            .font(.system(size: 12, weight: .medium)) 
                            .padding(.horizontal, 12) 
                            .padding(.vertical, 4) 
                            .background(isOpen ? Color.green : Color.blue.opacity(0.7)) 
                            .foregroundColor(.white)
                            .cornerRadius(12) 
                    }
                    
                    Spacer()
                    
                    if let nextOpenInterval = item.nextOpenInterval() {
                        formatTimeInterval(nextOpenInterval.dateInterval)
                            .font(.system(size: 12)) 
                    } else {
                        Text("Closed")
                            .font(.system(size: 12, weight: .regular)) 
                            .foregroundColor(Color(.darkGray))
                    }
                }
                
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 12, weight: .medium)) 
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(isExpanded ? nil : .spring(response: 0.6, dampingFraction: 1.0), value: isExpanded)
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
                let isCurrentDay = index == currentDayOfWeek
                
                HStack() {
                    Text(day)
                        .font(.system(size: 12, weight: isCurrentDay ? .bold : .regular)) 
                        .foregroundColor(.black)
                        .padding(.leading, 55)
                        .lineLimit(1) 
                        .lineSpacing(0) 
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    hoursView(for: dayOfWeek, isCurrentDay: isCurrentDay)
                        .padding(.trailing, 55)
                        .lineLimit(1) 
                        .lineSpacing(0) 
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(height: 22) 
                .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 6)
        .background(Color.white)
    }
    
    private func toggleWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 1.0)) {
            isExpanded.toggle()
        }
    }
    
    private func hoursView(for day: DayOfWeek, isCurrentDay: Bool) -> some View {
        let defaultText = Text("Closed")
            .font(.system(size: 12, weight: isCurrentDay ? .bold : .regular))
            .foregroundColor(Color(.darkGray))
        
        // Default if no weekly hours are available
        guard let weeklyHours = item.weeklyHours else {
            return defaultText
        }
        
        let intervals = weeklyHours.hoursForWeekday(day)
        
        guard !intervals.isEmpty, 
              !intervals.allSatisfy({ $0.dateInterval.duration <= 0 }),
              let interval = intervals.first else {
            return defaultText
        }
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        guard let start = interval.dateInterval.start.timeOnly(),
              let end = interval.dateInterval.end.timeOnly() else {
            return defaultText
        }
        
        let timeText = formatter.string(from: start, to: end)
        return Text(timeText)
            .foregroundColor(Color(.darkGray))
            .font(.system(size: 12, weight: interval.dateInterval.contains(Date()) ? .bold : .regular))
    }
    
    private func formatTimeInterval(_ interval: DateInterval) -> some View {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let text: String
        if let start = interval.start.timeOnly(),
           let end = interval.end.timeOnly() {
            text = formatter.string(from: start, to: end)
        } else {
            text = ""
        }
        return Text(text)
            .foregroundColor(Color(.darkGray))
            .font(.system(size: 12, weight: interval.contains(Date()) ? .bold : .regular))  
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Preview

struct OpenTimesCard_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
    
    struct PreviewWrapper: View {
        @StateObject private var sizeReporter = SizeReporter()
        
        var body: some View {
            OpenTimesCard(item: ClosedItem())
                .environmentObject(sizeReporter)
                .frame(width: 350)
                .background(Color(UIColor.systemGroupedBackground))
                .padding()
        }
    }
    
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
}

