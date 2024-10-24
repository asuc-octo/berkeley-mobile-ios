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
                
                print("Start hour: \(startHour) end hour: \(endHour)")
                                    
                if endTimeString.hasSuffix(dateFormatter.amSymbol!)
                    || ((startHour != 12) && (startHour > endHour))  {
                    processedString += " \(dateFormatter.amSymbol!)"
                } else {
                    processedString += " \(dateFormatter.pmSymbol!)"
                }
            }
        }
        
        print("Processed String: \(processedString)")
        
        if let date = dateFormatter.date(from: processedString) {
            // Combine with today's date to form a complete date object
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: baseDate)
        } else {
            return nil
        }
    }
    
}
