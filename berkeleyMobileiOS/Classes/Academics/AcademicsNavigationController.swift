//
//  AcademicsNavigationController.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/17/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class AcademicsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        LibraryDataSource.fetchLibraries { (_ libraries: [Library]?) in
            if libraries == nil
            {
                print("ERROR @ AcademicsNavigationController failed to fetch Libraries")
            }
            print(libraries ?? "couldn't print libraries")
        }
        
        // Do any additional setup after loading the view.
        LibraryDataSource.fetchLibraries { (_ libraries: [Library]?) in
            if libraries == nil
            {
                print("ERROR @ AcademicsNavigationController failed to fetch Libraries")
            }
            print(libraries ?? "couldn't print libraries")
        }
        
        CampusResourceDataSource.fetchCampusResources { (_ campusResources: [CampusResource]?) in
            if campusResources == nil
            {
                print("ERROR @ CAmpusresouce")
            }
            print(campusResources ?? "can't priint resouce");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Page Tab Bar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "library")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
    }
}
