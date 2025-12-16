//
//  FeedbackFormPresenter.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

protocol FeedbackFormPresenterDelegate: AnyObject {
    func feedbackFormDidPresent(withViewController viewController: UIViewController)
}

class FeedbackFormPresenter {
    private(set) var feedbackFormViewModel = FeedbackFormViewModel()
    
    weak var delegate: FeedbackFormPresenterDelegate?
    
    var currNumAppLaunchForFeedbackForm: Int {
        return UserDefaults.standard.integer(forKey: .numAppLaunchForFeedbackForm)
    }
    
    func attemptShowFeedbackForm(isForced: Bool = false) {
        Task {
            let formConfig = await feedbackFormViewModel.fetchFeedbackFormConfig()
            showFeedbackFormIfPossible(withConfig: formConfig, isForced: isForced)
        }
    }
    
    private func showFeedbackFormIfPossible(withConfig formConfig: FeedbackFormConfig?, isForced: Bool) {
        guard let formConfig else {
            return
        }
    
        if isForced || currNumAppLaunchForFeedbackForm >= formConfig.numToShow {
            let feedbackFormView = FeedbackFormView(viewModel: feedbackFormViewModel, config: formConfig)
            DispatchQueue.main.async {
                self.delegate?.feedbackFormDidPresent(withViewController: UIHostingController(rootView: feedbackFormView))
            }
        } else {
            UserDefaults.standard.set(currNumAppLaunchForFeedbackForm + 1, forKey: .numAppLaunchForFeedbackForm)
        }
    }
}
