//
//  ImageViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/10/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

/// Functionality for TableViewCells and CollectionViewCells to easily load images using ImageLoader
protocol ImageViewCell: class {
    /// The ImageView used to display the image
    var cellImageView: UIImageView { get }
    /// The currently loading task, if any
    var currentLoadUUID: UUID? { get set }
    /// Cancel the current load, if any, when the cell is reused. Prevents images replacing each other with fast scrolling, long loads when scrolling through many cells.
    func cancelImageOnReuse()
    /// Update the ImageView by loading the image if necessary, or set to default image
    func updateImage(item: HasImage)
    
    /// The default image to use for before images load or if an image never loads
    static var defaultImage: UIImage? { get }
}

extension ImageViewCell {
    
    func cancelImageOnReuse() {
        if let currentLoadUUID = self.currentLoadUUID {
            ImageLoader.shared.cancelLoad(currentLoadUUID)
        }
        cellImageView.image = type(of: self).defaultImage
    }
    
    func updateImage(item: HasImage) {
        cellImageView.image = type(of: self).defaultImage
        if let itemImage = item.image {
            cellImageView.image = itemImage
        } else if let url = item.imageURL {
            self.currentLoadUUID = ImageLoader.shared.getImage(url: url) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.cellImageView.image = image
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
