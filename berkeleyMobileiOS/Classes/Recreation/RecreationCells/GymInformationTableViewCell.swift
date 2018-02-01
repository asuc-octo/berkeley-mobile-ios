//
//  GymInformationTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 10/13/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymInformationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconInfo: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
