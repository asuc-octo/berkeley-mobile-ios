//
//  GymClassTableHeaderView.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 2/28/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassTableHeaderView: UITableViewCell {

    @IBOutlet var headerAbbreviation: UILabel!
    @IBOutlet var headerDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
