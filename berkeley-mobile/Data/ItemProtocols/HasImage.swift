//
//  HasImage.swift
//  bm-persona
//
//  Created by Shawn Huang on 6/27/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

protocol HasImage {
    var imageURL: URL? { get }
    var image: UIImage? { get }
}

extension HasImage {
    /// Getter for image is to return the image if already cached
    var image: UIImage? {
        get {
            guard let url = imageURL else { return nil }
            return ImageLoader.shared.getImageIfLoaded(url: url)
        }
    }
}
