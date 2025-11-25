//
//  DistanceLabelView.swift
//  berkeley-mobile
//
//  Created by Ananya Dua on 11/24/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct DistanceLabelView: View {
    let distance: Double?
    
    var body: some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundStyle(Color(BMColor.blackText))
                .font(.system(size: 12))
            
            Text("\(distance ?? 0.0, specifier: "%.1f") mi")
                .foregroundStyle(Color(BMColor.blackText))
                .font(Font(BMFont.light(12)))
        }
    }
}
