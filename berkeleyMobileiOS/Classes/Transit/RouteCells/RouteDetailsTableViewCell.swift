//
//  RouteDetailsTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 11/16/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class RouteDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var stopName: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
