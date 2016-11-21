//
//  AcademicsViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/30/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
class AcademicsViewController: BaseViewController {
    
    var academicDict = [
        0 : ["Anthropology", "Bioscience", "Business", "Chemistry", "Doe", "Earth Science", "East Asian", "Education Psychology", "Engineering", "Environmental Design", "Ethic Studies", "Graduate Services", "Governmental Studies", "Labor & Employment", "Main Stacks", "Math and Stats", "Moffit", "Music", "North", "Physics", "Social Research", "South/Southeast Asian"],
        1 : ["Main Stacks", "Moffitt", "Kresge", "Earth Science", "Environmental Design"],
        2 : ["Resources yay"]
        ]
    
    //Sets up initial tab look for this class
    override func viewDidLoad() {
        self.sectionNames = ["Libraries", "Reservable Study Spaces", "Resources"]
        self.baseTableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        cell.collectionCellNames = academicDict[indexPath.section]!
        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
    }

}
