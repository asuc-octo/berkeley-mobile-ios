//
//  BaseViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/30/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var baseTitleLabel: UILabel!
    @IBOutlet weak var baseTableView: UITableView!
    
    // HARD CODE
    var sectionNames = [String!]()
    var resources = [String:[Resource]]()
    var sectionNamesByIndex = [Int:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")! as! HomeTableViewCell
        
        let sectionName = sectionNamesByIndex[indexPath.section]!
        if self.resources[sectionName] != nil {
            let res = self.resources[sectionName]!
            cell.collectionCellNames = res.map { (resource) in resource.name }
            cell.collectionCellImageURLs = res.map { (resource) in resource.imageURL }
        }
        
        if let layout = cell.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.homeCollectionView.delegate = cell
        cell.homeCollectionView.dataSource = cell
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hello")
//        let index = indexPath.row
//        self.performSegue(withIdentifier: "toGymDetail", sender: index)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
}
