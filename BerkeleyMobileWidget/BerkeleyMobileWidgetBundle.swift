//
//  BerkeleyMobileWidgetBundle.swift
//  BerkeleyMobileWidget
//
//  Created by Justin Wong on 4/13/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FirebaseCore
import WidgetKit
import SwiftUI

@main
struct BerkeleyMobileWidgetBundle: WidgetBundle {
    init() {
        configureFirebaseIfNeeded()
    }

    var body: some Widget {
        GymOccupancyWidget()
    }

    private func configureFirebaseIfNeeded() {
        guard FirebaseApp.app() == nil else {
            return
        }
        FirebaseApp.configure()
    }
}
