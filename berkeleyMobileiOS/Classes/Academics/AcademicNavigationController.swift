//
//  AcademicNavigationController.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/1/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class AcademicNavigationController: ResourceNavigationController {
    
    typealias IBObjectType = AcademicNavigationController
    
    override class var componentID: String { return className(IBObjectType.self) }
    
    override class func fromIB() -> IBObjectType {
        return UIStoryboard.academics.instantiateViewController(withIdentifier: self.componentID) as! IBObjectType
    }
    
    
    override var tabBarIcon: UIImage? { return #imageLiteral(resourceName: "library_transparent") }

}
