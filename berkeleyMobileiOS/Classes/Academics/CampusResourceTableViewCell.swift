//
//  CampusResourceTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh on 3/10/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class CampusResourceTableViewCell: UITableViewCell {

    @IBOutlet weak var main_image: UIImageView!
    @IBOutlet weak var resource_name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
