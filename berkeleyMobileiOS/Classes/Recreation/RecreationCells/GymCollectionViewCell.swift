//
//  GymCollectionViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/27/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)

class GymCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gymImage: UIImageView!
    
    @IBOutlet weak var gymName: UILabel!
    
    @IBOutlet weak var gymStatus: UILabel!
    
}
