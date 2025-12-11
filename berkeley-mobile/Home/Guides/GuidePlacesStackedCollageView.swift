//
//  GuidePlacesStackedCollageView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/3/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct GuidePlacesStackedCollageView: View {
    private struct Constants {
        static let maxVisible = 3
        static let maxDrag: CGFloat = 20
        static let commitThreshold: CGFloat = 35
        
        static let cardHeight: CGFloat = 150
        static let cardWidth: CGFloat = 80
    }
    
    var guide: Guide
    
    // First angle corresponds to the furthest back image
    private let angles: [CGFloat] = [-10.0, 10.0, 0.0]
    
    @State private var frontIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var hasCommittedSwipe = false
    
    var body: some View {
        ZStack {
            if guide.places.isEmpty {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
            } else {
                let places = guide.places
                let total = places.count
                let indices = visibleIndices(total: total, frontIndex: frontIndex)
                let count = indices.count
                
                ForEach(Array(indices.enumerated()), id: \.1) { depth, idx in
                    let place = places[idx]
                    let angleBase = angles[angles.count - count + depth]
                    let isFront = (depth == indices.count - 1)
                    
                    BMCachedAsyncImageView(imageURL: place.imageURL, aspectRatio: .fill)
                        .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .rotationEffect(
                            .degrees(
                                angleBase + (isFront ? Double(dragOffset / 10) : 0)
                            )
                        )
                        .offset(x: isFront ? dragOffset : 0)
                        .zIndex(Double(depth))
                        .gesture(
                            isFront
                            ? DragGesture()
                                .onChanged { value in
                                    guard !hasCommittedSwipe else {
                                        return
                                    }
                                    
                                    let t = value.translation.width
                                    dragOffset = min(max(t, -Constants.maxDrag), Constants.maxDrag)
                                    
                                    if abs(t) >= Constants.commitThreshold {
                                        hasCommittedSwipe = true
                                        withAnimation(.spring()) {
                                            frontIndex = (frontIndex - 1 + total) % total
                                            dragOffset = 0
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    if hasCommittedSwipe {
                                        hasCommittedSwipe = false
                                        dragOffset = 0
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                            : nil
                        )
                }
            }
        }
        .animation(.spring(), value: frontIndex)
    }
    
    // MARK: - Helpers
    
    private func visibleIndices(total: Int, frontIndex: Int) -> [Int] {
        guard total > 0 else {
            return []
        }
        let count = min(Constants.maxVisible, total)
        
        switch count {
        case 1:
            return [frontIndex]
        case 2:
            return [
                (frontIndex - 1 + total) % total, // back
                frontIndex                        // front
            ]
        default:
            return [
                (frontIndex - 2 + total) % total, // back
                (frontIndex - 1 + total) % total, // middle
                frontIndex                        // front
            ]
        }
    }
}
