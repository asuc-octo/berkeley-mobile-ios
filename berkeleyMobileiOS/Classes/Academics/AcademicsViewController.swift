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
    
    override func viewDidLoad() {
        sectionNamesByIndex = [0:kLibraries, 1:kCampusResources]
        sectionNames = [kLibraries, kCampusResources]
        let loadScreen = LoadingScreen.sharedInstance.getLoadingScreen()
        self.view.addSubview(loadScreen)
        
        LibraryDataSource.fetchLibraries { (_ libraries: [Library]?) in
            if libraries == nil {
                print("[ERROR @ AcademicsViewController] failed to fetch Libraries")
                LoadingScreen.sharedInstance.removeLoadingScreen()
            }
            self.resources[kLibraries] = libraries!
            self.baseTableView.reloadData()
            
            if self.resources.count == self.sectionNames.count {
                LoadingScreen.sharedInstance.removeLoadingScreen()
            }
        }
        CampusResourceDataSource.fetchCampusResources { (_ campusResources: [CampusResource]?) in
            if campusResources == nil {
                print("[ERROR @ AcademicsViewController] failed to fetch Campus Resources")
                LoadingScreen.sharedInstance.removeLoadingScreen()
            }
            self.resources[kCampusResources] = campusResources!
            self.baseTableView.reloadData()
            
            if self.resources.count == self.sectionNames.count {
                LoadingScreen.sharedInstance.removeLoadingScreen()
            }
        }
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
            
            let libraryMapVC = segue.destination as! LibraryMapViewController
            
            libraryMapVC.libraries = self.resources[kLibraries]! as! [Library]
        }
    }

}
