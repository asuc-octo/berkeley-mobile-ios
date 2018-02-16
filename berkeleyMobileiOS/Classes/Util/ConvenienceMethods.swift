//
//  ConvenienceMethods.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Material
let kAPIURL = "https://asuc-mobile-development.herokuapp.com/api/"
class ConvenienceMethods: NSObject {
    static func setCurrentTabStyle(pageTabBarVC: PageTabBarController, ForSelectedViewController selectedViewController: UIViewController) {
        var count = 0
        for vc in (pageTabBarVC.viewControllers) {
//            let children = vc.childViewControllers
//            let firstChild = children.first as! ResourceGroupViewController
//            let firstChildTypesArr = firstChild.types
            if (vc == selectedViewController)   {
//                    vc.pageTabBarItem.image = #imageLiteral(resourceName: "beartransitColoredIcon")
                    //Make Current Tab Image Bigger
                    vc.pageTabBarItem.imageEdgeInsets = UIEdgeInsetsMake(3,3,3,3)
                    vc.pageTabBarItem.imageView?.tintColor = Color.blue.base
                }
            else {
                    //Make Current Tab Image Smaller
                    vc.pageTabBarItem.imageEdgeInsets = UIEdgeInsetsMake(3,3,3,3)
                    vc.pageTabBarItem.imageView?.tintColor = Color.grey.base
            }
            count += 1
        }
    }
    static func getAllBTStops() -> Dictionary<String, Dictionary<String, Any>> {
        return allStops
    }
    
    static func getAllStops() -> Dictionary<String, Dictionary<String, Any>> {
        return allBTStops
    }
    
}


extension PageTabBarController
{
    func highlightTabItem(of viewController: UIViewController)
    {
        let controllers = self.viewControllers
        guard controllers.contains(viewController) else {
            return
        }
        
        controllers.forEach
        { 
            let item = $0.pageTabBarItem
            item.imageView?.tintColor = Color.grey.base
            item.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
        }
        
        let selectedItem = viewController.pageTabBarItem
        selectedItem.imageView?.tintColor = Color.blue.base
        selectedItem.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
    }
}

extension Array
{
    func filterDuplicates(includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]
    {
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}
