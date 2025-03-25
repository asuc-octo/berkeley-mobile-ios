//
//  BMCalendarView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/23/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

typealias BMDateEntryPair = (date: Date, entry: EventCalendarEntry?)

class BMCalendarViewModel: ObservableObject {
    @Published var dateEntryPairs = [BMDateEntryPair]()
    
    var calendarEntries: [EventCalendarEntry] {
        dateEntryPairs.compactMap { $0.entry }
    }
    
    private let calendar = Calendar.current
    
    init() {
        populateDates()
    }
    
    func setCalendarEntries(for entries: [EventCalendarEntry]) {
        dateEntryPairs = dateEntryPairs.map { datePair in
            let entry = entries.first(where: { $0.date.isSameDay(as: datePair.date) })
            return (datePair.date, entry)
        }
    }
    
    private func populateDates() {
        let startOfToday = Date().getStartOfDay()
        guard let dateTwoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: startOfToday),
              let dateOneWeekFromToday = calendar.date(byAdding: .day, value: 7, to: startOfToday),
              let nextSaturday = calendar.date(byAdding: .day, value: DayOfWeek.saturday.rawValue - DayOfWeek.weekday(dateOneWeekFromToday).rawValue + 1, to: dateOneWeekFromToday) else {
            return
        }
        
        var dates = [Date]()
        var currentDate = dateTwoWeeksAgo

        while currentDate <= nextSaturday {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        self.dateEntryPairs = dates.map {(date: $0, entry: nil)}
    }
}


// MARK: - BMCalendarView

struct BMCalendarView: View {
    @EnvironmentObject var viewModel: BMCalendarViewModel
    
    var didSelectDay: ((Int) -> Void)?
    
    private let columns = Array(repeating: GridItem(.flexible(minimum: 30)), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            daysOfWeekHeader
            daysView
        }
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
    
    var datePair: BMDateEntryPair
    var didSelectDay: ((Int) -> Void)?
    
    private var hasEntry: Bool {
        datePair.entry != nil
    }
    
    var body: some View {
        Button(action: {
            guard hasEntry else {
                return
            }
            peformBounceAnimation()
            didSelectDay?(datePair.date.get(.day))
        }) {
            Text("\(Calendar.current.component(.day, from: datePair.date))")
                .foregroundStyle(getForegroundColor())
                .font(Font(datePair.date.isToday() ? BMFont.bold(20) : BMFont.light(18)))
                .frame(width: 30, height: 30)
                .padding(3)
                .background(hasEntry ? Color(datePair.entry!.color) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(isTapped ? 1.2 : 1)
        }
        .disabled(hasEntry ? false : true)
    }
    
    private func getForegroundColor() -> Color {
        if datePair.entry != nil {
            Color(.white)
        } else {
            Color(datePair.date.isToday() ? BMColor.Calendar.blackText : BMColor.Calendar.grayedText)
        }
    }
    
    private func peformBounceAnimation() {
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
    let viewModel = BMCalendarViewModel()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let eventCalendarEntries = [
        EventCalendarEntry(name: "", date: Date(), end: Date(), descriptionText: "", location: "", imageURL: "", sourceLink: ""),
        EventCalendarEntry(name: "", date: tomorrow, end: tomorrow, descriptionText: "", location: "", imageURL: "", sourceLink: "")
    ]
    viewModel.setCalendarEntries(for: eventCalendarEntries)
    
    return BMCalendarView()
        .environmentObject(viewModel)
}
