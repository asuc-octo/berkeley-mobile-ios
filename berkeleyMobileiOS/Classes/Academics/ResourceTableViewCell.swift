//
//  ResourceTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/2/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class ResourceTableViewCell: UITableViewCell {

    @IBOutlet weak var resourceImage: UIImageView!
    
    @IBOutlet weak var resourceName: UILabel!
    @IBOutlet weak var resourceStatus: UILabel!
    
    @IBOutlet weak var resourceHours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
