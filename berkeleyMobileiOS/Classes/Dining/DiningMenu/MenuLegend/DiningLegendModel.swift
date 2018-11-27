//
//  DiningLegendModel.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Bunarjo on 10/29/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class DiningLegendModel {
    struct Constants {
        static let restrictionCellHeight: CGFloat = 40
        static let maxLegendHeight: CGFloat = 280
        static let cellColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 245/255)
    }

    private let restrictionToImageName = ["Contains Alcohol" : "ALCOHOL",
                "Egg" : "EGG",
                "Fish" : "FISH",
                "Contains Gluten" : "GLUTEN",
                "Halal" : "HALAL",
                "Kosher" : "KOSHER",
                "Milk" : "MILK",
                "Peanuts" : "PEANUTS",
                "Contains Pork" : "PORK",
                "Sesame" : "SESAME",
                "Shellfish" : "SHELLFISH",
                "Soybeans" : "SOYBEAN",
                "Tree Nuts" : "TREENUTS",
                "Vegan Option" : "VEGAN",
                "Vegetarian Option" : "VEGETARIAN",
                "Wheat" : "WHEAT"]
    
    private var restrictionsToDisplay: [String] = []
    
    func resetModel() {
        restrictionsToDisplay = []
    }
    
    func addRestrictions(restrictions: [String]) {
        for restriction in restrictions {
            if restrictionToImageName.keys.contains(restriction) && !restrictionsToDisplay.contains(restriction) {
                restrictionsToDisplay.append(restriction)
            }
        }
    }
    
    func numberOfRestrictionsToDisplay() -> Int {
        return restrictionsToDisplay.count
    }
    
    func getRestrictionToDisplay(atIndex index: Int) -> String {
        return restrictionsToDisplay[index]
    }
    
    func getImageToDisplay(atIndex index: Int) -> UIImage {
        return UIImage(named: restrictionToImageName[restrictionsToDisplay[index]]!)!
    }
}
