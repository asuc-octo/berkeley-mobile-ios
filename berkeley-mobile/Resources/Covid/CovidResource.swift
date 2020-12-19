//
//  CovidResource.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 11/21/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

class CovidResource {
    
    let dailyScreeningLink: String
    let lastUpdated: String
    let positivityRate: String
    let totalCases: String
    let dailyIncrease: String
    
    init(dailyScreeningLink: String, lastUpdated: Double, positivityRate: String, totalCases: String, dailyIncrease: String) {
        self.dailyScreeningLink = dailyScreeningLink
        
        if lastUpdated != 0.0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a 'on' MM-dd-yyyy"
            self.lastUpdated = formatter.string(from: Date(timeIntervalSince1970: lastUpdated))
        } else {
            self.lastUpdated = "Unknown"
        }
        
        self.positivityRate = positivityRate
        self.totalCases = totalCases
        self.dailyIncrease = dailyIncrease
    }
    
}
