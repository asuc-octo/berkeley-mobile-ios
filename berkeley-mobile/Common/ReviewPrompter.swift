//
//  ReviewPrompter.swift
//  berkeley-mobile
//
//  Created by Jayana Nanayakkara on 9/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

final class ReviewPrompter {
    private let numLaunchesForReview: Int = 30
    static let shared = ReviewPrompter()
    func shouldPromptForReview() -> Bool {
        let launches = UserDefaults.standard.integer(forKey: UserDefaultsKeys.numAppLaunchForAppStoreReview)
        if launches > numLaunchesForReview {
            UserDefaults.standard.set(0, forKey: UserDefaultsKeys.numAppLaunchForAppStoreReview.rawValue)
            return true
        }
        return false
    }
    func presentReviewIfNeeded() {
        guard shouldPromptForReview() else {
            return
        }
        
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
