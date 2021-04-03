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
    open var animating: Bool = false
    open var labels: [String]! {
        didSet {
            if animating {
                self.performBatchUpdates({
                    let indexSet = IndexSet(integer: 0)
                    self.reloadSections(indexSet)
                }, completion: nil)
            } else {
                self.reloadData()
            }

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
            if let label = labels[safe: indexPath.row] {
                card.label.text = label
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = FilterViewCell()
        cell.label.text = labels[indexPath.row]
        return cell.intrinsicContentSize
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Deselect on second tap when multiple selection is disabled.
        guard let item = collectionView.cellForItem(at: indexPath) else { return true }
        if item.isSelected {
            collectionView.deselectItem(at: indexPath, animated: false)
            self.collectionView(collectionView, didDeselectItemAt: indexPath)
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterDelegate?.filterView(self, didSelect: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        filterDelegate?.filterView(self, didDeselect: indexPath.row)
    }
    
    func deselectAllItems() {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems {
            deselectItem(at: indexPath, animated: false)
        }
    }
    
    func selectItem(index: Int) {
        guard index < labels.count else { return }
        self.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
    }
}
