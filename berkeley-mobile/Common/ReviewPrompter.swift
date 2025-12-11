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

enum ReviewPrompter {
    private static let numLaunchesForReview: Int = 30

    private static func shouldPromptForReview() -> Bool {
        let key = UserDefaultsKeys.numAppLaunchForAppStoreReview.rawValue
        let launches = UserDefaults.standard.integer(forKey: key)
        if launches == numLaunchesForReview {
            UserDefaults.standard.set(0, forKey: key)
            return true
        }
        return false
    }

    @MainActor
    static func presentReviewIfNeeded() {
        guard shouldPromptForReview() else {
            return
        }

        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
            
        }
    }
}
