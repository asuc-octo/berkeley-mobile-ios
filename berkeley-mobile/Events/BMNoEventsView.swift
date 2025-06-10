//
//  BMNoEventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/10/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMNoEventsView: View {
    var body: some View {
        BMContentUnavailableView(iconName: "", title: "No Events Available", subtitle: "Please try again.")
    }
}

#Preview {
    BMNoEventsView()
}
