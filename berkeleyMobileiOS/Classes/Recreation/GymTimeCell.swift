//
//  GymTimeCell.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/19/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymTimeCell: UITableViewCell {
    
    @IBOutlet var gymStartEndTime: UILabel!
    @IBOutlet var gymStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
