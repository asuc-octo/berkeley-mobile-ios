
import Foundation

/**
 * Provides several conviences methods for Date.
 */
extension Date {
    /// Returns `date` with (hour:min) of this Date.
    func sameTime(on date: Date) -> Date? {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day], from: date)
        
        var components = calendar.dateComponents([.hour, .minute], from: self)
        components.year = now.year
        components.month = now.month
        components.day = now.day
        
        return calendar.date(from: components)
    }
    
    /// Returns today with (hour:min) of this Date.
    func sameTimeToday() -> Date? {
        return sameTime(on: Date())
    }
    
    /// Returns soonest date with (weekday:hour:min) of this Date.
    func sameDayThisWeek() -> Date? {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour, .minute, .weekday], from: self)
        if self == calendar.startOfDay(for: Date()) {
            return self
        }
        return calendar.nextDate(after: calendar.startOfDay(for: Date()), matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
    }
    
    /// Returns if the given date is tomorrow's date based on some date.
    static func isDateTomorrow(baseDate: Date, date: Date) -> Bool {
        let calendar = Calendar.current

        if let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: baseDate)) {
            return calendar.isDate(date, inSameDayAs: startOfTomorrow)
        } else {
            return false
        }
    }

    /// Returns a date with this date's hour and minute component only.
    func timeOnly() -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.hour, .minute], from: self))
    }
    
    /// Returns a date with this date's year, month, and day component only.
    func dateOnly() -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self))
    }
    
    /// Returns the weekday as an integer (0 -> Sunday, 6 -> Saturday)
    func weekday() -> Int {
        return Calendar.current.component(.weekday, from: self) - 1
    }
    
    /// Returns whether this Date is between Date range [a, b] inclusive.
    func isBetween(_ a: Date?, _ b: Date?) -> Bool {
        if a == nil || b == nil {
            return false 
        }
        
        return a! <= self && self <= b!
    }
    
    /// Returns true if this Date is earlier or equal to given other.
    static func <= (_ this: inout Date, _ other: Date) -> Bool {
        return (this < other) || (this == other)
    }
    
    /// Returns true if this Date is later or equal to given other.
    static func >= (_ this: inout Date, _ other: Date) -> Bool {
        return (this > other) || (this == other)
    }
    
    /// Returns true if the Date is before noon.
    static func isBeforeNoon(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour < 12
    }

    /// Returns the date given the provided date components.
    static func getTodayShiftDate(for date: Date, hourComponent: Int?, minuteComponent: Int?, secondComponent: Int?) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        var shiftedTodayDate = DateComponents()
        shiftedTodayDate.year = components.year
        shiftedTodayDate.month = components.month
        shiftedTodayDate.day = components.day
        shiftedTodayDate.hour = hourComponent
        shiftedTodayDate.minute = minuteComponent
        shiftedTodayDate.second = secondComponent
        
        return calendar.date(from: shiftedTodayDate)!
    }
    
    /// Set the year to the given date.
    static func setYear(_ year: Int, to date: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.year = year
        return calendar.date(from: components)
    }
    
    /// Returns a `Bool` if the date components are equivalent to the given date.
    func doesDateComponentsAreEqualTo(hour: Int, minute: Int, sec: Int) -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return components.hour == hour && components.minute == minute && components.second == sec
    }
    
    /// Returns a string representation of the given date. With support for "Noon".
    func getDateString(withFormatter formatter: DateFormatter) -> String {
        if self.doesDateComponentsAreEqualTo(hour: 12, minute: 0, sec: 0) {
            return "Noon"
        }
        
        return formatter.string(from: self)
    }
    
    /// Returns if the given date is within the past week
    func isWithinPastWeek() -> Bool {
        let now = Date()
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        return self > oneWeekAgo && self <= now
    }
    
}
