//
//  CovidResource.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 3/13/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Foundation

class CovidResource {

    let dailyScreeningLink: String
    @Display var lastUpdated: String
    @Display var positivityRate: String
    @Display var totalCases: String
    @Display var dailyIncrease: String

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
