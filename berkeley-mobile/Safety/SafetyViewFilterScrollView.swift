//
//  SafetyViewFilterScrollView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct SafetyViewFilterScrollView: View {
    @EnvironmentObject var safetyViewModel: SafetyViewModel
    
    @Binding var drawerViewState: BMDrawerViewState
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(safetyViewModel.selectedSafetyLogFilterStates, id: \.id) { filterState in
                    HStack {
                        Text(filterState.rawValue.capitalized)
                            .font(Font(BMFont.regular(16)))
                            .foregroundStyle(.white)
                        Button(action: {
                            withAnimation {
                                if let removeIndex = safetyViewModel.selectedSafetyLogFilterStates.firstIndex(of: filterState) {
                                    safetyViewModel.selectedSafetyLogFilterStates.remove(at: removeIndex)
                                    drawerViewState = .small
                                }
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .modify {
                                    if #available(iOS 26.0, *) {
                                        $0.foregroundStyle(.white)
                                    } else {
                                        $0.foregroundStyle(.regularMaterial)
                                    }
                                }
                        }
                    }
                    .padding(8)
                    .modify {
                        if #available(iOS 26.0, *) {
                            $0.glassEffect(.regular.tint(.gray).interactive(), in: .capsule)
                        } else {
                            $0.background(.gray.opacity(0.6))
                            $0.clipShape(.capsule)
                        }
                    }
                }
            }
        }
        .modify {
            if #available(iOS 17.0, *) {
                $0.scrollClipDisabled()
            }
        }
        .scrollIndicators(.hidden)
    }
}
