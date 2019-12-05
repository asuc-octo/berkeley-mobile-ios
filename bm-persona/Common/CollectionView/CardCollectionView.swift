//
//  CardCollectionView.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/8/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class CardCollectionView: UICollectionView {

    static let kCellIdentifier: String = "cardCell"
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 13
        layout.itemSize = CardCollectionViewCell.kCardSize
        
        super.init(frame: frame, collectionViewLayout: layout)

        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionView.kCellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
