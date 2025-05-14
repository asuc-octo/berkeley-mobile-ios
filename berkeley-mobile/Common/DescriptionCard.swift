//
//  DescriptionCard.swift
//  berkeley-mobile
//
//  Created by Yihang Chen on 5/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMDescriptionCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(Font(BMFont.bold(16)))
                .foregroundColor(Color(BMColor.blackText))
            
            Text(description)
                .font(Font(BMFont.light(12)))
                .foregroundColor(Color(BMColor.blackText))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
    }
} 