//
//  AcademicNavigationController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/1/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class AcademicNavigationController: UINavigationController, IBInitializable {
    
    typealias IBObjectType = AcademicNavigationController
    
    static var componentID: String { return className(IBComponent.self)}
    
    static func fromIB() -> IBObjectType {
        return UIStoryboard.academics.instantiateViewController(withIdentifier: self.componentID) as! IBObjectType
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preparePageTabBarItem()
    }
    //Customize Tab Bar Presence
    private func preparePageTabBarItem() {
        pageTabBarItem.image = #imageLiteral(resourceName: "library_transparent")
        pageTabBarItem.image = pageTabBarItem.image!.withRenderingMode(.alwaysTemplate)
        pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    //Make sure tab bar is highlighted properly
    override func viewDidAppear(_ animated: Bool) {
        ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: self)
        self.navigationBar.isHidden = true;
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
