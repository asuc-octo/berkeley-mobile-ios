//
//  RecreationViewController.swift
//  berkeleyMobileiOS
//
//  Created by Alex Takahashi on 10/30/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import Material

fileprivate let kGyms = "Gyms"
fileprivate let kClasses = "GymClasses"

class RecreationViewController: BaseViewController {
    //Sets up initial tab look for this class
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    override func viewDidLoad() {
        sectionNamesByIndex = [0:kGyms, 1: kClasses]
        sectionNames = [kGyms, kClasses]
        
        let loadScreen = LoadingScreen.sharedInstance.getLoadingScreen()
        self.view.addSubview(loadScreen)
        
        GymDataSource.fetchResources
        { (_ resources: [Resource]?) in
            
            guard let gyms = resources as? [Gym] else
            {
                print("[ERROR @ RecreationViewController] failed to fetch Gyms")
                LoadingScreen.sharedInstance.removeLoadingScreen()
                return
            }
            
            self.resources[kGyms] = gyms
        
        }
        
        //fetch resources for class too
        GymClassDataSource.fetchResources
        {(_ resources: [Resource]?) in
            
            guard let gymClasses = resources as? [GymClass] else
            {
                print("[ERROR @ RecreationViewController] failed to fetch GymClasses")
                LoadingScreen.sharedInstance.removeLoadingScreen()
                return
            }
            
            self.resources[kClasses] = gymClasses
            self.baseTableView.reloadData()
            
            if self.resources.count == self.sectionNames.count
            {
                LoadingScreen.sharedInstance.removeLoadingScreen()
            }

        }

    }
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
    }
    
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "50x50-Gym_32x32")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    
    //Moving to Gym Map View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeader = UITableViewHeaderFooterView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RecreationViewController.moveToMapView))
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
        
        sectionHeader.addGestureRecognizer(tapGesture)
        return sectionHeader
    }
    
    
    func moveToMapView() {
        self.performSegue(withIdentifier: "toGymMapView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if (segue.identifier == "toGymMapView") {
            let gymMapVC = segue.destination as! GymsMapListViewController
            gymMapVC.gyms = self.resources[kGyms]! as! [Gym]
        }
        
        if (segue.identifier == "toGymDetail") {
            let index = sender as! Int!
            let gymDetailVC = segue.destination as! GymDetailViewController
            gymDetailVC.gym = self.resources[kGyms]![index!] as? Gym

        }
    }
    
    

}
