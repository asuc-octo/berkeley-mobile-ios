//
//  DiningGroupCell.swift
//  berkeleyMobileiOS
//
//  Created by Bohui Moon on 12/19/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

fileprivate let kLocationTileID = "LocationTile"

/**
 *
 */
class DiningGroupCell: UITableViewCell, RequiresData, UICollectionViewDataSource, UICollectionViewDelegate
{
    private var halls: [DiningHall]!
    
    @IBOutlet private weak var groupLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /**
     *
     */
    override func awakeFromNib()
    {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    

    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (name: String, halls: [DiningHall])
    
    public func setData(_ data: DataType)
    {
        self.groupLabel.text = data.name
        
        self.halls = data.halls
        self.collectionView.reloadData()
    }
    
    
    // ========================================
    // MARK: - UICollectionViewDataSource
    // ========================================
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return halls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLocationTileID, for: indexPath) as! LocationTile
        cell.setData(halls[indexPath.item])
        
        return cell
    }
}
