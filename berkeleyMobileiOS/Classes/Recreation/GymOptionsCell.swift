//
//  GymOptionsCell.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 1/24/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymOptionsCell: UITableViewCell {
    
    @IBOutlet var gymPhoneButton: UIButton!
    @IBOutlet var gymDirectionsButton: UIButton!
    @IBOutlet var gymWebsiteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
