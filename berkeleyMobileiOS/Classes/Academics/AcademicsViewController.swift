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
    //Sets up initial tab look for this class
    override func viewDidLoad() {
        self.sectionNames = ["Doe", "Main Stacks"]
        self.baseTableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        cell.collectionCellNames = ["aaa", "bbb", "ccc"]
        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let v = UITableViewHeaderFooterView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AcademicsViewController.moveToMapView))
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
    
        v.addGestureRecognizer(tapGesture)
        
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func moveToMapView() {
        self.performSegue(withIdentifier: "toLibraryMapView", sender: self)
    }

}
