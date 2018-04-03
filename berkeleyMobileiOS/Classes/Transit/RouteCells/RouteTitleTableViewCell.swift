//
//  RouteTitleTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Anthony Kim on 3/19/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import Foundation
import UIKit

class RouteTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var bus1: UIImageView!
    @IBOutlet weak var bus2: UIImageView!
    @IBOutlet weak var busStartNum: UILabel!
    @IBOutlet weak var busEndNum: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
