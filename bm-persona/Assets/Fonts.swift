//
//  Fonts.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

struct Font {
    static let regular = {
        (size: CGFloat) in
        UIFont(name: "Raleway-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let bold = {
        (size: CGFloat) in
        UIFont(name: "Raleway-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let semibold = {
        (size: CGFloat) in
        UIFont(name: "Raleway-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let thin = {
        (size: CGFloat) in
        UIFont(name: "Raleway-Thin", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let medium = {
        (size: CGFloat) in
        UIFont(name: "Raleway-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
