//
//  NSCoding+Extension.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 11/15/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import Foundation


extension NSCoding where Self: NSObject {
    
    static func unsecureUnarchived(from data: Data) -> Self? {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            let obj = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
            if let error = unarchiver.error {
                print("Error:\(error)")
            }
            return obj
        } catch {
            print("Error:\(error)")
        }
        return nil
    }
    
}
