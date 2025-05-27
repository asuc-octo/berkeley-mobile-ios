//
//  BMActionButton.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMActionButton: View {
    var title: String
    var backgroundColor = Color(uiColor: BMColor.ActionButton.background)
    var showShadow: Bool = true
    var completionHandler: (() -> Void)?
    
    var body: some View {
        Button(action: {
            completionHandler?()
        }) {
            HStack {
                Spacer()
                Text(title)
                    .foregroundStyle(.white)
                    .font(Font(BMFont.medium(12)))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(showShadow ? 0.25 : 0), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BMActionButton(title: "Book a Study Room") {
        print("Pressed Button")
    }
    .padding()
}
