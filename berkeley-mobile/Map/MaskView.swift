//
//  MaskView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/17/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

// Empty view that appears in the background during search
struct MaskView: View {
    var body: some View {
        VStack{}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial)
    }
}

#Preview {
    MaskView()
}
