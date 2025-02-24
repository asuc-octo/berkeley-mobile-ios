//
//  Fonts.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


struct BMFont {
    static let regular = {
        (size: CGFloat) -> UIFont in
        return UIFont(name: "Apercu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let bold = {
        (size: CGFloat) in
        UIFont(name: "Apercu-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let medium = {
        (size: CGFloat) in
        UIFont(name: "Apercu-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let mediumItalic = {
        (size: CGFloat) in
        return UIFont(name: "Apercu-MediumItalic", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static let light = {
        (size: CGFloat) in
        UIFont(name: "Apercu-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
