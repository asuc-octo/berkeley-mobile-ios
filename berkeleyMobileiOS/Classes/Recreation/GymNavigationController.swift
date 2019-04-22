//
//  GymNavigationController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/8/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymNavigationController: ResourceNavigationController {

    typealias IBObjectType = GymNavigationController
    
    override class var componentID: String { return className(IBObjectType.self)}
    
    override class func fromIB() -> IBObjectType {
        return UIStoryboard.gym.instantiateViewController(withIdentifier: self.componentID) as! IBObjectType
    }
    
    
    override var tabBarIcon: UIImage? { return #imageLiteral(resourceName: "gym-uncolored") }

}
