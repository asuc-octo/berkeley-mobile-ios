//
//  DepthButtonStyle.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 11/12/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI


struct DepthButtonStyle: ButtonStyle {
    var color: Color
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .background {
                ZStack {
                    self.getBGView()
                        .opacity(0.5)
                        .offset(y: configuration.isPressed ? 0 : 8)
                        .padding(.horizontal, 2)

                    self.getBGView()
                }
            }
            .rotation3DEffect(.degrees(20), axis: (x: 1.0, y: 0.0, z: 0.0))
            .offset(y: configuration.isPressed ? 8 : 0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
    
    func getBGView() -> some View {
        LinearGradient(
            colors: [Color(UIColor(color).lighter(by: 10) ?? UIColor(color.opacity(0.5))), color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
