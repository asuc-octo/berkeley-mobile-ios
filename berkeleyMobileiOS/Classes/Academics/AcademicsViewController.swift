//
//  AcademicsViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/30/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material
fileprivate let kLibraries = "Libraries"
fileprivate let kCampusResources = "Campus Resources"
class AcademicsViewController: BaseViewController {
    //Sets up initial tab look for this class
    var resources = [String:[Resource]]()
    let sectionNamesByIndex : [Int:String] = [0:kLibraries, 1:kCampusResources]
    
    override func viewDidLoad() {
        LibraryDataSource.fetchLibraries { (_ libraries: [Library]?) in
            if libraries == nil
            {
                print("[ERROR @ AcademicsViewController] failed to fetch Libraries")
            }
            self.resources[kLibraries] = libraries!
            self.sectionNames = [String](self.resources.keys)
            self.baseTableView.reloadData()
        }
        CampusResourceDataSource.fetchCampusResources { (_ campusResources: [CampusResource]?) in
            if campusResources == nil
            {
                print("[ERROR @ AcademicsViewController] failed to fetch Campus Resources")
            }
            self.resources[kCampusResources] = campusResources!
            self.sectionNames = [String](self.resources.keys)
            self.baseTableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        let sectionName = sectionNamesByIndex[indexPath.row]!
        let res = self.resources[sectionName]!
        cell.collectionCellNames = res.map { (resource) in resource.name }
        cell.collectionCellImageURLs = res.map { (resource) in resource.imageURL }

        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeader = UITableViewHeaderFooterView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AcademicsViewController.moveToMapView))
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
    
        sectionHeader.addGestureRecognizer(tapGesture)
        return sectionHeader
    }
    
    func moveToMapView() {
        self.performSegue(withIdentifier: "toLibraryMapView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toLibraryMapView") {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }

}
