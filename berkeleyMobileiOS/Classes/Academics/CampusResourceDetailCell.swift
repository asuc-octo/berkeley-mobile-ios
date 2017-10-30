//
//  CampusResourceCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 10/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResourceDetailCell: UITableViewCell {

    
    
    @IBOutlet weak var campResIconInfo: UILabel!
    
    
    @IBOutlet weak var campResIconImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
