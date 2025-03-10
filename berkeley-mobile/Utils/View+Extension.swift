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
