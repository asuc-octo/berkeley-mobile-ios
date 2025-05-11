//
//  BMCalendarView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/23/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

typealias BMDateHasEntryPair = (date: Date, hasEntry: Bool)

class CalendarViewModel: ObservableObject {
    @Published var dateEntryPairs = [BMDateHasEntryPair]()
    var entries = [EventCalendarEntry]()
    
    private let calendar = Calendar.current
    
    init() {
        populateDates()
    }
    
    func setEntries(_ entries: [EventCalendarEntry]) {
        self.entries = entries
        
        dateEntryPairs = dateEntryPairs.map { datePair in
            let hasEntry = entries.contains(where: { $0.date.isSameDay(as: datePair.date) })
            return (datePair.date, hasEntry)
        }
    }
    
    private func populateDates() {
        guard let sundayTwoWeeksAgo = Date.getDateCertainWeeksRelativeToToday(numWeeks: -2, dayOfWeek: .sunday),
            let saturdayTwoWeeksFromNow = Date.getDateCertainWeeksRelativeToToday(numWeeks: 2, dayOfWeek: .saturday) else {
            return
        }
        
        var dates = [Date]()
        var currentDate = sundayTwoWeeksAgo

        while currentDate <= saturdayTwoWeeksFromNow {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        self.dateEntryPairs = dates.map {(date: $0, hasEntry: false)}
    }
}


// MARK: - BMCalendarView

struct BMCalendarView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    
    var didSelectDay: ((Int) -> Void)?
    
    private let columns = Array(repeating: GridItem(.flexible(minimum: 30)), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            daysOfWeekHeader
            daysView
        }
        .frame(height: 180)
        .padding()
    }
    
    private var daysOfWeekHeader: some View {
        ForEach(DayOfWeek.allCases, id: \.rawValue) { dayOfWeek in
            Text(dayOfWeek.charRepresentation())
                .foregroundStyle(Color(BMColor.Calendar.dayOfWeekHeader))
                .font(Font(BMFont.medium(18)))
        }
    }
    
    private var daysView: some View {
        ForEach(viewModel.dateEntryPairs, id: \.date) { datePair in
            CalendarEntryButton(datePair: datePair, didSelectDay: didSelectDay)
        }
    }
}


// MARK: - CalendarEntryButton

struct CalendarEntryButton: View {
    @State private var isTapped = false
    
    var datePair: BMDateHasEntryPair
    var didSelectDay: ((Int) -> Void)?
    
    var body: some View {
        Button(action: {
            guard datePair.hasEntry else {
                return
            }
            performBounceAnimation()
            didSelectDay?(datePair.date.get(.day))
        }) {
            Text("\(Calendar.current.component(.day, from: datePair.date))")
                .foregroundStyle(getForegroundColor())
                .font(Font(datePair.date.isToday() ? BMFont.bold(20) : BMFont.light(18)))
                .frame(width: 30, height: 30)
                .padding(3)
                .background(getBackgroundColor())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(isTapped ? 1.2 : 1)
        }
        .disabled(datePair.hasEntry ? false : true)
    }
    
    private func getForegroundColor() -> Color {
        if datePair.hasEntry {
            .white
        } else {
            Color(datePair.date.isToday() ? BMColor.Calendar.blackText : BMColor.Calendar.grayedText)
        }
    }
    
    private func getBackgroundColor() -> Color {
        guard datePair.hasEntry else {
           return .clear
        }
        
        if datePair.date.isToday() {
            return Color(BMColor.selectedButtonBackground)
        } else {
            return .gray.opacity(0.7)
        }
    }
    
    private func performBounceAnimation() {
        withAnimation(.bouncy) {
            isTapped.toggle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.bouncy) {
                isTapped.toggle()
            }
        }
    }
}

#Preview {
    let viewModel = CalendarViewModel()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let eventCalendarEntries = [
        EventCalendarEntry(name: "", date: Date(), end: Date(), descriptionText: "", location: "", imageURL: "", sourceLink: ""),
        EventCalendarEntry(name: "", date: tomorrow, end: tomorrow, descriptionText: "", location: "", imageURL: "", sourceLink: "")
    ]
    viewModel.setEntries(eventCalendarEntries)
    
    return BMCalendarView()
        .environmentObject(viewModel)
}
