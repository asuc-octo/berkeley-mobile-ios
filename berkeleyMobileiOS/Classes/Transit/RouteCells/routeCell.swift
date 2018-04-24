//
//  routeCell.swift
//  berkeleyMobileiOS
//
//  UITableViewCell that displays route information as search result.
//  Used in RouteResultViewController
//
//  Created by Akilesh Bapu on 1/29/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class routeCell: UITableViewCell {
    
    @IBOutlet weak var sideColorView: UIView!
    
    @IBOutlet weak var busImageView: UIImageView!
    @IBOutlet weak var busLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    
}
