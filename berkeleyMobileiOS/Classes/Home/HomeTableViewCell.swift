//
//  HomeTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/23/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    // Hardcode
    var collectionCellNames = ["RSF", "Memorial Stadium", "Yolo"]
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.homeCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCellNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.homeCollectionView.delegate = self
        self.homeCollectionView.dataSource = self
        let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.nameLabel.text = collectionCellNames[indexPath.row]
        return cell
    }

}
