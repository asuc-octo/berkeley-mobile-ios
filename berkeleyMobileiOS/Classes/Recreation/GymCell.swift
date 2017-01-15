//
//  GymCell.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/2/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymCell: UITableViewCell {

    @IBOutlet var gymName: UILabel!
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
