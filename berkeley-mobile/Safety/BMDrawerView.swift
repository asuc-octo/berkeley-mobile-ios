//
//  BMDrawerView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

enum BMDrawerViewState {
    case small, medium, large
}

struct BMDrawerView<Content: View>: View {
    private let content: Content

    @State private var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.8 / 2
    @State private var currentOffset:CGFloat = 0
    @State private var endOffset:CGFloat = 0
    @State private var drawerViewState = BMDrawerViewState.medium

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.4))
            .frame(
                    width: 26,
                    height: 6
            )
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                indicator
                self.content
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(Color(.white))
            .clipShape(
                .rect(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )
            .offset(y:startingOffset)
            .offset(y:currentOffset)
            .offset(y:endOffset)
            .gesture(
                withAnimation(.interactiveSpring()) {
                    DragGesture()
                        .onChanged{ value in
                            withAnimation(.spring()){
                                currentOffset = value.translation.height
                            }
                        }
                        .onEnded{ value in
                            withAnimation(.spring()){
                                if currentOffset < -50  {
                                    switch drawerViewState {
                                    case .small:
                                        drawerViewState = .medium
                                        endOffset = -startingOffset / 7
                                    case .medium:
                                        drawerViewState = .large
                                        endOffset = -startingOffset * 0.9
                                    case .large:
                                        break
                                    }
                                } else if currentOffset > 50 {
                                    switch drawerViewState {
                                    case .small:
                                        break
                                    case .medium:
                                        drawerViewState = .small
                                        endOffset = startingOffset * 0.9
                                    case .large:
                                        drawerViewState = .medium
                                        endOffset = -startingOffset / 7
                                    }
                                }
                                currentOffset = 0
                            }
                        }
                }
            )
        }
        .edgesIgnoringSafeArea([.bottom, .horizontal])
        .shadow(color: Color(hue: 1.0, saturation: 0.0, brightness: 0.0, opacity: 0.08), radius: 12, y: -8)
    }
}
