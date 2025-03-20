//
//  BMFilterButton.swift
//  berkeley-mobile
//
//  Created by Hetvi Patel on 3/19/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMFilterButton: View {
    let title: String
    @Binding var isSelected: Bool
    
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
                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                .frame(height: 28)
        }
    }
}

struct InteractiveButtonPreview: View {
    @State private var nearbySelected = false
    @State private var openSelected = true
    
    var body: some View {
        HStack {
            BMFilterButton(title: "Nearby", isSelected: $nearbySelected)
            BMFilterButton(title: "Open", isSelected: $openSelected)
        }
        .padding()
    }
}

struct BMFilterButton_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveButtonPreview()
            .previewLayout(.sizeThatFits)
    }
}
