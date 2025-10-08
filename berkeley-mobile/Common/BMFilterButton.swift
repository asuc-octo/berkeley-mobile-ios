//
//  BMFilterButton.swift
//  berkeley-mobile
//
//  Created by Hetvi Patel on 4/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMFilterButton: View {
    @Binding var isSelected: Bool
    let title: String
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .background(isSelected ? Color(uiColor: BMColor.selectedButtonBackground) : Color(uiColor: BMColor.cardBackground))
                .foregroundColor(isSelected ? .white : Color(uiColor: BMColor.secondaryText))
                .cornerRadius(14)
                .frame(height: 28)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BMFilterButtonPreviewView: View {
    @State private var nearbySelected = false

    var body: some View {
        HStack {
            BMFilterButton(isSelected: $nearbySelected, title: "Nearby")
        }
        .padding()
    }
}

#Preview {
    BMFilterButtonPreviewView()
}
