//
//  Exensions.swift
//  berkeleyMobileiOS
//
//  Created by Bohui Moon on 10/15/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation

/**
 * Provides .isNil and .notNil for quicker optional nil checking.
 */
extension Optional
{
    var isNil: Bool
    {
        get {
            return self == nil
        }
    }
    
    var notNil: Bool
    {
        get {
            return self != nil
        }
    }
}


