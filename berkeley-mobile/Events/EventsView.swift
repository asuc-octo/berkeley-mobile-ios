//
//  EventsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct EventsView: View {
    @State private var tabSelectedIndex = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                BMTopBlobView(imageName: "BlobTopRight", xOffset: 50, yOffset: -45, width: 300, height: 150)
                
                VStack {
                    SegmentedControlView(
                        tabNames: ["Academic", "Campus-Wide"],
                        selectedTabIndex: $tabSelectedIndex
                    )
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    
                    ZStack {
                        AcademicCalendarView()
                            .opacity(tabSelectedIndex == 0 ? 1 : 0)
                        CampusCalendarView()
                            .opacity(tabSelectedIndex == 1 ? 1 : 0)
                    }
                }
                .navigationTitle("Events")
            }
            .background(Color(BMColor.cardBackground))
        }
    }
}

#Preview {
    EventsView()
}
