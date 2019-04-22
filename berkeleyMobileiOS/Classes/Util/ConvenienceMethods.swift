//
//  ConvenienceMethods.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/6/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import Foundation
import Material

class ConvenienceMethods: NSObject {
    
    static func getAllBTStops() -> Dictionary<String, Dictionary<String, Any>> {
        return allBTStops
    }
    
    static func getAllStops() -> Dictionary<String, Dictionary<String, Any>> {
        return allBTStops
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
