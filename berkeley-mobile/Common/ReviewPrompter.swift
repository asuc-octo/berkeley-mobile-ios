//
//  ReviewPrompter.swift
//  berkeley-mobile
//
//  Created by Jayana Nanayakkara on 9/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import SwiftUI
final class ReviewPrompter {
    static let shared = ReviewPrompter()
    
    private let successfulEventKey = "successfulEventCount"
    private let lastPromptDateKey = "lastPromptDate"
    private let promptCountPastYearKey = "promptCountPastYear"
    
    private let successfulEventThreshold = 3
    private let yearlyPromptLimit = 3
    private let minSecondsBetweenPrompts: TimeInterval = 86_400
    
    private var successfulEventCount: Int {
        get { UserDefaults.standard.integer(forKey: successfulEventKey) }
        set { UserDefaults.standard.set(newValue, forKey: successfulEventKey) }
    }
    
    private var lastPromptDate: Date? {
        get { UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date}
        set { UserDefaults.standard.set(newValue, forKey: lastPromptDateKey) }
    }
    
    private var promptCountPastYear: Int {
        get { UserDefaults.standard.integer(forKey: promptCountPastYearKey) }
        set { UserDefaults.standard.set(newValue, forKey: promptCountPastYearKey) }
    }
    
    func incSuccessfulEvent() {
        successfulEventCount += 1
    }
    
//    func resetForTesting() {
//            UserDefaults.standard.removeObject(forKey: successfulEventKey)
//            UserDefaults.standard.removeObject(forKey: lastPromptDateKey)
//            UserDefaults.standard.removeObject(forKey: promptCountPastYearKey)
//        }
        
    func shouldPromptForReview() -> Bool {
        if successfulEventCount >= successfulEventThreshold &&
            (lastPromptDate == nil || Date().timeIntervalSince(lastPromptDate!) > minSecondsBetweenPrompts) &&
            promptCountPastYear < yearlyPromptLimit{
            lastPromptDate = Date()
            promptCountPastYear += 1
            successfulEventCount = 0
            return true
        }
        return false
    }
}
