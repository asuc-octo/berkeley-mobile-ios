//
//  HomeViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/23/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    override func viewDidLoad() {
        self.sectionNames = ["Gyms and Pools", "Libraries"]
        self.baseTitleLabel.text = "Home"
        self.baseTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        if indexPath.section == 0 {
            cell.collectionCellNames = ["RSF", "Stadium Gym", "Spieker Pool", "Edwards Track", "Hearst Gym Pool"]
        } else {
            cell.collectionCellNames = ["yolo"]
        }
        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
    }
    
}