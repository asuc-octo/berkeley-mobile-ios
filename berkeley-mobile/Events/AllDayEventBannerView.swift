//
//  AllDayEventBannerView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/27/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct AllDayEventBannerView: View {
    @InjectedObservable(\.eventsViewModel) private var eventsViewModel

    var event: BMEventCalendarEntry

    var body: some View {
        Capsule()
            .fill(.gray.opacity(0.5))
            .frame(height: 30)
            .overlay(
                HStack(spacing: 10) {
                    Text("All Day")
                        .font(Font(BMFont.bold(15)))
                    Text(event.name)
                        .font(Font(BMFont.regular(12)))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            )
    }
}
