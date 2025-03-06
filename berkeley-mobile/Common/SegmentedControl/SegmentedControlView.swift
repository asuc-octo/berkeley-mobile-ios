//
//  SegmentedControlView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/26/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct SegmentedControlView: View {
    
    private struct Constants {
        static let tabSpacing: CGFloat = 20
        static let textSize: CGFloat = 18
        static let indicatorOffset: CGFloat = 1
        static let indicatorHeight: CGFloat = 8
    }
    
    var tabNames: [String]
    @Binding var selectedTabIndex: Int
    
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Constants.tabSpacing) {
            ForEach(Array(tabNames.enumerated()), id: \.offset) { index, tabName in
                Button(action: {
                    withAnimation {
                        selectedTabIndex = index
                    }
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
                
                if index != tabNames.count - 1 {
                    Spacer()
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
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
            SegmentedControlView(tabNames: ["Dining", "Academic Life", "Study"], selectedTabIndex: $selectedTabIndex)
        }
    }
    return PreviewWrapper()
}

