//
//  CampusEventCollectionView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 10/3/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

//import UIKit
//
//class CampusEventCollectionView: UICollectionView {
//
//    static let kCellIdentifier = "campusEventCollection"
//
//    init(frame: CGRect) {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 13
//        layout.itemSize = CampusEventCollectionViewCell.kCardSize
//
//        super.init(frame: frame, collectionViewLayout: layout)
//
//        backgroundColor = .clear
//        layer.masksToBounds = false
//        showsVerticalScrollIndicator = false
//        showsHorizontalScrollIndicator = false
//        register(CampusEventCollectionViewCell.self, forCellWithReuseIdentifier: CampusEventCollectionView.kCellIdentifier)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
