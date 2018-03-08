//
//  GymClassInfoTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/8/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var instructor: UILabel!
    
    @IBOutlet weak var room: UILabel!
    
    @IBOutlet weak var gym: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
