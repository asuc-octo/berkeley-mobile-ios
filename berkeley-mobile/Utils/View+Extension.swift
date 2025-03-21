//
//  View+Extension.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 2/27/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI


struct BMControlButtonStyle: ButtonStyle {
    static let widthAndHeight: CGFloat = 45
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: BMControlButtonStyle.widthAndHeight, height: BMControlButtonStyle.widthAndHeight)
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

struct Cardify: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(BMColor.cardBackground)) 
            )
            .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 0)
    }
}

extension View {
    func positionedAtTop() -> some View {
        self.modifier(OpenTimesCardTopModifier())
    }
  
    func cardify() -> some View {
        self.modifier(Cardify())
    }
}
