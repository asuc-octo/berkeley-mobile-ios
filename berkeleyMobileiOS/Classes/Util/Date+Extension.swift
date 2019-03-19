
import Foundation

/**
 * Provides several conviences methods for Date.
 */
extension Date
{
    // Returns today with (hour:min) of this Date. 
    func sameTimeToday() -> Date?
    {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month, .day], from: Date())
        
        var components = calendar.dateComponents([.hour, .minute], from: self)
        components.year = now.year
        components.month = now.month
        components.day = now.day
        
        return calendar.date(from: components)
    }
    
    // Returns soonest date with (weekday:hour:min) of this Date.
    func sameDayThisWeek() -> Date?
    {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour, .minute, .weekday], from: self)
        if self == calendar.startOfDay(for: Date()) {
            return self
        }
        return calendar.nextDate(after: calendar.startOfDay(for: Date()), matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
    }
    
    // Returns the weekday as an integer (0 -> Sunday, 6 -> Saturday)
    func weekday() -> Int
    {
        return Calendar.current.component(.weekday, from: self) - 1
    }
    
    // Returns whether this Date is between Date range [a, b] inclusive.
    func isBetween(_ a: Date?, _ b: Date?) -> Bool
    {
        if a.isNil || b.isNil {
            return false 
        }
        
        return a! <= self && self <= b!
    }
    
    // Returns true if this Date is earlier or equal to given other.
    static func <= (_ this: inout Date, _ other: Date) -> Bool
    {
        return (this < other) || (this == other)
    }
    
    // Returns true if this Date is later or equal to given other.
    static func >= (_ this: inout Date, _ other: Date) -> Bool
    {
        return (this < other) || (this == other)
    }
}
