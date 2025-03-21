//
//  View+Extension.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI


struct HomeMapControlButtonStyle: ButtonStyle {
    static let widthAndHeight: CGFloat = 45
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: HomeMapControlButtonStyle.widthAndHeight, height: HomeMapControlButtonStyle.widthAndHeight)
            .background(
                Circle()
                    .fill(.thinMaterial)
            )
            .overlay(
                Circle()
                    .strokeBorder(.gray, lineWidth: 0.5)
            )
    }
}


// MARK: - OpenTimesCard Positioning

struct OpenTimesCardTopModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        
            VStack {
                content
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                Spacer()
            }
        }
    }
}

extension View {
    func positionedAtTop() -> some View {
        self.modifier(OpenTimesCardTopModifier())
    }
}
