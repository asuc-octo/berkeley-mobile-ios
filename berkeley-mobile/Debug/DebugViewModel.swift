//
//  DebugViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation

class DebugViewModel {
    
    private let feedbackFormPresenter: FeedbackFormPresenter
    
    init(feedbackFormPresenter: FeedbackFormPresenter) {
        self.feedbackFormPresenter = feedbackFormPresenter
    }
    
    func presentFeedbackForm() {
        feedbackFormPresenter.attemptShowFeedbackForm(isForced: true)
    }
}
