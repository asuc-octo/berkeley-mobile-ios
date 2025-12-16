//
//  DebugViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

@Observable
class DebugViewModel {
    
    var feedbackFormConfig: FeedbackFormConfig?
    
    private(set) var feedbackFormPresenter: FeedbackFormPresenter
    
    init(feedbackFormPresenter: FeedbackFormPresenter) {
        self.feedbackFormPresenter = feedbackFormPresenter
    }
    
    func presentFeedbackForm() {
        feedbackFormPresenter.attemptShowFeedbackForm(isForced: true)
    }
    
    func fetchFeedbackFormConfig() {
        Task {
            feedbackFormConfig = await feedbackFormPresenter.feedbackFormViewModel.fetchFeedbackFormConfig()
        }
    }
}
