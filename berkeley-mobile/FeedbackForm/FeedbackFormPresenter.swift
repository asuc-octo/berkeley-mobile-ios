//
//  FeedbackFormPresenter.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

protocol FeedbackFormPresenterDelegate: AnyObject {
    func presentFeedbackForm(withViewController viewController: UIViewController)
}

class FeedbackFormPresenter {
    private let feedbackFormViewModel = FeedbackFormViewModel()
    
    weak var delegate: FeedbackFormPresenterDelegate?
    
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
    
        let numAppLaunchForFeedbackForm = UserDefaults.standard.integer(forKey: .numAppLaunchForFeedbackForm)
        if isForced || numAppLaunchForFeedbackForm >= formConfig.numToShow {
            let feedbackFormView = FeedbackFormView(viewModel: feedbackFormViewModel, config: formConfig)
            DispatchQueue.main.async {
                self.delegate?.presentFeedbackForm(withViewController: UIHostingController(rootView: feedbackFormView))
            }
        } else {
            UserDefaults.standard.set(numAppLaunchForFeedbackForm + 1, forKey: .numAppLaunchForFeedbackForm)
        }
    }
}
