//
//  FilterView.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol FilterViewDelegate {
    func filterView(_ filterView: FilterView, didSelect index: Int)
    func filterView(_ filterView: FilterView, didDeselect index: Int)
}

// MARK: - FilterView

class FilterView: UICollectionView {

    static let kCellIdentifier: String = "filterCell"
    
    open var filterDelegate: FilterViewDelegate?
    open var labels: [String]! {
        didSet {
            reloadData()
        }
    }
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 13
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        backgroundColor = .clear
        layer.masksToBounds = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        allowsMultipleSelection = true
        register(FilterViewCell.self, forCellWithReuseIdentifier: FilterView.kCellIdentifier)
        
        labels = []
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - UICollectionViewDelegate

extension FilterView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterView.kCellIdentifier, for: indexPath)
        if let card = cell as? FilterViewCell {
            card.label.text = labels[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = FilterViewCell()
        cell.label.text = labels[indexPath.row]
        return cell.intrinsicContentSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterDelegate?.filterView(self, didSelect: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        filterDelegate?.filterView(self, didDeselect: indexPath.row)
    }
    
}
