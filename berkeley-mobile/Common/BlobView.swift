//
//  BlobView.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/13/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class BlobView: UIView {
    private var leftBlobView: UIImageView!
    private var rightBlobView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlobs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBlobs() {
        
    }
}
