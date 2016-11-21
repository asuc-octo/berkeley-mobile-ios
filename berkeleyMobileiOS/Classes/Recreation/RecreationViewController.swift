//
//  RecreationViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/30/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
class RecreationViewController: BaseViewController {
    
    //Sets up initial tab look for this class
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    override func viewDidLoad() {
        self.sectionNames = ["Facilities", "Courts", "Aquatics", "Fields", "Group Classes"]
        self.baseTableView.reloadData()
    }
    
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        if indexPath.section == 0 {
            cell.collectionCellNames = ["RSF", "Stadium", "Edwards Track"]
        } else if indexPath.section == 1 {
            cell.collectionCellNames = ["Field House", "RSF Gold", "RSF Blue", "Golden Bear", "Hearst"]
        } else if indexPath.section == 2 {
            cell.collectionCellNames = ["Gold Bear", "Hearst", "Spieker", "Strawberry Canyon"]
        } else if indexPath.section == 3 {
            cell.collectionCellNames = ["Underhill", "Maxwell"]
        } else {
            cell.collectionCellNames = ["All Around", "Aqua", "Cardio", "Core", "Dance", "Mind/Body", "Strength"]
        }
        print(indexPath.section)
        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
        
    }

    
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "50x50-Gym_32x32")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }

}
