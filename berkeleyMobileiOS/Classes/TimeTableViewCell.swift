//
//  TimeTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 4/15/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class TimeTableViewCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
