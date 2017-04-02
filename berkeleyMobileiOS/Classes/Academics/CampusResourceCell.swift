//
//  CampusResourceCell.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/18/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResourceCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var favoriteButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
