//
//  BMDrawerView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

enum BMDrawerViewState: Int {
    case small = 1, medium = 2, large = 3
}

struct BMDrawerView<Content: View>: View {
    private let content: Content
    private let hPadding: CGFloat
    private let vPadding: CGFloat

    @State private var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.8 / 2
    @State private var currentOffset:CGFloat = 0
    @State private var endOffset:CGFloat = 0
    @Binding var drawerViewState: BMDrawerViewState

    init(
        drawerViewState: Binding<BMDrawerViewState>,
        hPadding: CGFloat = 5.0,
        vPadding: CGFloat = 10.0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.hPadding = hPadding
        self.vPadding = vPadding
        self._drawerViewState = drawerViewState
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    indicator
                    Spacer()
                }
                .padding(.vertical, 10)
                self.content
                    .padding(.top, vPadding)
            }
            .padding(.horizontal, hPadding)
            // The multiplier to geometry.size.height prevents the bottommost content from being obscured by the tabbar
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(.regularMaterial)
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
                            // Prevent user from dragging drawer view upwards at .large state
                            guard !(currentOffset < 0 && drawerViewState == .large) else {
                                return
                            }
                            
                            withAnimation(.spring){
                                currentOffset = value.translation.height
                            }
                        }
                        .onEnded{ value in
                            withAnimation(.spring){
                                panSetDrawerState()
                            }
                        }
                }
            )
        }
        .edgesIgnoringSafeArea([.bottom, .horizontal])
        .shadow(color: Color(hue: 1.0, saturation: 0.0, brightness: 0.0, opacity: 0.08), radius: 12, y: -8)
        .onChange(of: drawerViewState) { [drawerViewState] newState in
            let diff = drawerViewState.rawValue - newState.rawValue
            
            withAnimation(.spring) {
                if diff < 0 {
                    expandDrawerState(to: newState)
                } else {
                    shrinkDrawerState(to: newState)
                }
                
                currentOffset = 0
            }
        }
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.6))
            .frame(
                    width: 30,
                    height: 6
            )
    }
    
    private func panSetDrawerState() {
        if currentOffset < -50  {
            switch drawerViewState {
            case .small:
                drawerViewState = .medium
            case .medium:
                drawerViewState = .large
            case .large:
                currentOffset = 0
                break
            }
        } else if currentOffset > 50 {
            switch drawerViewState {
            case .small:
                currentOffset = 0
                break
            case .medium:
                drawerViewState = .small
            case .large:
                drawerViewState = .medium
            }
        } else {
            currentOffset = 0
        }
    }
    
    private func shrinkDrawerState(to newState: BMDrawerViewState) {
        switch newState {
        case .small:
            endOffset = startingOffset * 0.5
        case .medium:
            endOffset = -startingOffset / 6.8
        case .large:
            break
        }
    }
    
    private func expandDrawerState(to newState: BMDrawerViewState) {
        switch newState {
        case .small:
            break
        case .medium:
            endOffset = -startingOffset / 6.8
        case .large:
            endOffset = -startingOffset * 0.95
        }
    }
}
