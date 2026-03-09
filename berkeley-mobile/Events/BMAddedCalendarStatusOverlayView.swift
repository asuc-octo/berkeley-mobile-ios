//
//  BMAddedCalendarStatusOverlayView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/26/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct BMAddedCalendarStatusOverlayView: View {
    @InjectedObject(\.eventsViewModel) private var eventsViewModel
    
    let event: BMEventCalendarEntry
    
    var body: some View {
        if eventsViewModel.doesEventExists(for: event) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addedCalendarStatusButton
                }
            }
            .padding(5)
        }
    }
    
    private var addedCalendarStatusButton: some View {
        Button(action: {
            let interval = event.startDate.timeIntervalSinceReferenceDate
            let url = URL(string: "calshow:\(interval)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.subheadline)
        }
        .buttonStyle(BMControlButtonStyle(widthAndHeight: 30))
    }
}
