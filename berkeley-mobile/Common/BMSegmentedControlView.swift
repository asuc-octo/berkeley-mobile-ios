//
//  BMSegmentedControlView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/26/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMSegmentedControlView: View {
    
    private struct Constants {
        static let tabSpacing: CGFloat = 20
        static let textSize: CGFloat = 18
        static let indicatorOffset: CGFloat = 1
        static let indicatorHeight: CGFloat = 8
    }
    
    var tabNames: [String]
    var tabVisibilityFilter: ((String) -> Bool)? = nil
    @Binding var selectedTabIndex: Int
    
    private var visibleTabs: [(offset: Int, element: String)] {
        tabNames.enumerated().filter { _, name in
            guard let tabVisibilityFilter else { return true }
            return tabVisibilityFilter(name)
        }
    }
    
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Constants.tabSpacing) {
            ForEach(Array(visibleTabs.enumerated()), id: \.offset) { visible, tab in
                let (index, tabName) = tab
                Button(action: {
                    selectedTabIndex = index
                }) {
                    VStack(spacing: Constants.indicatorOffset) {
                        Text(tabName)
                            .foregroundStyle(Color(uiColor: selectedTabIndex == index ? BMColor.primaryText : BMColor.secondaryText))
                            .font(Font(BMFont.bold(Constants.textSize)))
                        
                        if selectedTabIndex == index {
                            capsule
                        } else {
                            placeholderCapsule
                        }
                    }
                }
                
                if visible != visibleTabs.count - 1 {
                    Spacer()
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .animation(.default, value: selectedTabIndex)
    }
    
    private var capsule: some View {
        Capsule()
            .fill(Color(uiColor: BMColor.segmentedControlHighlight))
            .frame(height: Constants.indicatorHeight)
            .matchedGeometryEffect(id: "capsule", in: animation)
    }
    
    private var placeholderCapsule: some View {
        Capsule()
            .fill(.clear)
            .frame(height: Constants.indicatorHeight)
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State var selectedTabIndex = 0
        
        var body: some View {
            BMSegmentedControlView(tabNames: ["Dining", "Academic Life", "Study"], selectedTabIndex: $selectedTabIndex)
        }
    }
    return PreviewWrapper()
}

