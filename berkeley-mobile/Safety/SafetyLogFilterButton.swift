//
//  SafetyLogFilterButton.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct SafetyLogFilterButton: View {
    @Binding var safetyLogFilterStates: [BMSafetyLogFilterState]
    @Binding var drawerViewState: BMDrawerViewState
    
    var body: some View {
        Menu {
            Menu("Crime") {
                Button("Robbery", action: { addToSafetyLogFilterStates(for: .robbery)})
                Button("Aggravated Assault", action: { addToSafetyLogFilterStates(for: .aggravatedAssault )})
                Button("Burglary", action: { addToSafetyLogFilterStates(for: .burglary)})
                Button("Sexual Assault", action: {addToSafetyLogFilterStates(for: .sexualAssault)})
                Button("Others", action: {addToSafetyLogFilterStates(for: .others)})
            }
            Menu("When") {
                Button("Today", action: {addToSafetyLogFilterStates(for: .today)} )
                Button("This Week", action: {addToSafetyLogFilterStates(for: .thisWeek)} )
                Button("This Month", action: {addToSafetyLogFilterStates(for: .thisMonth)} )
                Button("This Year", action: {addToSafetyLogFilterStates(for: .thisYear)} )
            }
        } label: {
            if #available(iOS 26.0, *) {
                Image(systemName: safetyLogFilterStates.isEmpty ? "line.3.horizontal.decrease" :  "line.3.horizontal.decrease.circle.fill")
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.purple, lineWidth: 1.0)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.purple.opacity(0.6)))
                    .frame(width: 90, height: 35)
                    .overlay(
                        HStack {
                            Text("Filter")
                                .font(Font(BMFont.regular(18)))
                                .fontWeight(.bold)
                            Image(systemName: "chevron.down")
                        }
                            .foregroundStyle(.white)
                    )
            }
        }
        .menuOrder(.fixed)
    }
    
    private func addToSafetyLogFilterStates(for newFilterState: BMSafetyLogFilterState) {
        if !safetyLogFilterStates.contains(newFilterState) {
            withAnimation {
                safetyLogFilterStates.append(newFilterState)
                drawerViewState = .small
            }
        }
    }
}
