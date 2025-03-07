//
//  BMTopBlobView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMTopBlobView: View {
    var imageName: String
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            Image(imageName)
                .resizable()
                .offset(x: xOffset, y: yOffset)
                .frame(width: width, height: height)
                .edgesIgnoringSafeArea(.top)
                .frame(width: geo.size.width, height: geo.size.height , alignment: .topTrailing)
        }
    }
}

#Preview {
    BMTopBlobView(imageName: "BlobRight", xOffset: 30, width: 150, height: 150)
}
