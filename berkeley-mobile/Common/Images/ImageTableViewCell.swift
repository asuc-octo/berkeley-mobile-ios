//
//  ImageViewCell.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/10/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

protocol ImageViewCell: class {
    
    var cellImageView: UIImageView { get }
    var currentLoadUUID: UUID? { get set }
    func cancelImageOnReuse()
    func updateImage(item: HasImage)
    
}

extension ImageViewCell {
    
    func cancelImageOnReuse() {
        if let currentLoadUUID = self.currentLoadUUID {
            ImageLoader.shared.cancelLoad(currentLoadUUID)
        }
        cellImageView.image = nil
    }
    
    func updateImage(item: HasImage) {
        cellImageView.image = UIImage(named: "DoeGlade")
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
