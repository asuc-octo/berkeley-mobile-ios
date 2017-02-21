
import Foundation

/**
 * Specifies a range of time with start and end dates.
 * The ending `Date` must be later than the starting one.
 */
struct DateRange
{
    let start: Date
    let end: Date
    
    /**
     * Initialize range from specified `start` and `end`.
     * Returns `nil` if either are `nil` or `end` is earlier than `start`.
     */
    init?(start: Date?, end: Date?)
    {
        guard start.notNil && end.notNil && start! < end! else {
            return nil
        }
        
        self.start = start!
        self.end = end!
    }
    
    /// Inidicates whether the current time is within range.
    var isActive: Bool 
    {
        return Date().isBetween(start, end)
    }
    
    /// Inidicates whether the current time has past the `end`.
    var hasExpired: Bool
    {
        return end <= Date()
    }
    
    /// Indiciates whether the given `date` is within the range.
    func contains(_ date: Date) -> Bool
    {
        return date.isBetween(start, end)
    }
    
    /**
     * Returns description of format `"<start> <separator> <end>"` 
     * where `start` and `end` are converted using the given `DateFormatter`.
     */
    func description(withFormatter formatter: DateFormatter, separator: String = "~") -> String
    {
        return formatter.string(from: start) + " \(separator) " + formatter.string(from: end)
    }
}
