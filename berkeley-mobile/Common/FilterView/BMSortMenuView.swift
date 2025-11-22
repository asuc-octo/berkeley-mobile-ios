//
//  BMSortMenuView.swift
//  berkeley-mobile
//
//  Created by Ananya Dua on 11/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMSortMenuView: View {
    @Binding var selected: BMSortOption
    var options: [BMSortOption]
    
    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(option.displayTitle) {
                    selected = option
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down.circle")
                Text(selected.displayTitle)
            }
            .font(Font(BMFont.bold(14)))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(BMColor.cardBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
