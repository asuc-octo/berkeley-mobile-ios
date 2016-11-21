//
//  HomeViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/23/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
class HomeViewController: BaseViewController {
    //Sets up initial tab look for this class
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    override func viewDidLoad() {
        self.sectionNames = ["Gyms and Pools", "Libraries"]
        self.baseTitleLabel.text = "Home"
        self.baseTableView.reloadData()
        self.baseTableView.allowsSelection = false
    }
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
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
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "home-icon")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
//        pageTabBarItem.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    
}
