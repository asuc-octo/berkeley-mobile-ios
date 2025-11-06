//
//  BMCachedAsyncImageView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMCachedAsyncImageView: View {
    var imageURL: URL?
    var placeholderImage: UIImage?
    var aspectRatio: ContentMode = .fill
    
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            let image = self.image ?? placeholderImage
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
            }
        }
        .onAppear {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let imageURL {
            ImageLoader.shared.getImage(url: imageURL) { result in
                switch result {
                case .success(let image):
                    self.image = image
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    BMCachedAsyncImageView(imageURL: URL(string: "https://events.berkeley.edu/live/image/gid/84/width/200/height/200/crop/1/src_region/0,0,1080,1080/8428_NewEECSLogo-Livewhale.rev.1729531907.png"))
}
