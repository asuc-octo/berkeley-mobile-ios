//
//  String+Extension.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import Foundation

extension String {
    
    func convertToDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
        return dateFormatter.date(from: self)
    }
    
    func convertTimeStringToDate(baseDate: Date, endTimeString: String? = nil) -> Date? {
        guard !isEmpty else {
            return nil
        }

        var processedString = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = contains(":") ? "hh:mm a" : "hh a"
        dateFormatter.amSymbol = "a.m."
        dateFormatter.pmSymbol = "p.m."
        
        if self == "Noon" {
            processedString = "12 p.m."
        } else {
            let hasAMPMSymbol = hasSuffix(dateFormatter.amSymbol!) || hasSuffix(dateFormatter.pmSymbol!)
            
            if let endTimeString, count == 1 || !hasAMPMSymbol {
                guard let startHour = Int(String(self.first!)),
                      let endHour = Int(String(endTimeString.first!)) else {
                    return nil
                }
                                    
                if endTimeString.hasSuffix(dateFormatter.amSymbol!)
                    || ((startHour != 12) && (startHour > endHour))  {
                    processedString += " \(dateFormatter.amSymbol!)"
                } else {
                    processedString += " \(dateFormatter.pmSymbol!)"
                }
            }
        }
        
        if let date = dateFormatter.date(from: processedString) {
            // Combine with today's date to form a complete date object
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: baseDate)
        } else {
            return nil
        }
    }
    
    /// Converts a String with a time range like `"7:50 p.m. - 10:00 p.m."` into a `DateInterval`
    /// - Parameters:
    ///   - day: A date of the range. By default, set to the current date.
    ///   - timeZone: A time zone of the range. By default, set to `TimeZone.current`.
    /// - Returns: A an Optional `DateInterval` with the two dates of the range.
    func convertToDateInterval(on day: Date = Date(), timeZone: TimeZone = .current) -> DateInterval? {
        let cleaned = self
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .uppercased()

        let parts = cleaned.split(separator: "-", maxSplits: 1)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 2 else {
            return nil
        }
        
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        func hm(_ s: String) -> (h: Int, m: Int)? {
            let dateFormat = s.contains(":") ? "h:mm a" : "h a"
            guard let d = s.convertToDate(dateFormat: dateFormat) else {
                return nil
            }
            let dateComponents = calendar.dateComponents(in: timeZone, from: d)
            return (dateComponents.hour ?? 0, dateComponents.minute ?? 0)
        }

        guard let (startHour, startMinute) = hm(String(parts[0])),
              let (endHour, endMinute) = hm(String(parts[1])) else {
            return nil
        }

        guard let start = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: day),
              let endSame = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: day) else {
            return nil
        }

        let end = endSame >= start ? endSame : calendar.date(byAdding: .day, value: 1, to: endSame)!
        return DateInterval(start: start, end: end)
    }
}
