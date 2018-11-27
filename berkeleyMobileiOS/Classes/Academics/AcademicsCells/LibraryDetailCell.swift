//
//  LibraryDetailCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 10/26/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class LibraryDetailCell: TappableInfoTableViewCell {
    
    @IBOutlet weak var libraryIconImage: UIImageView!
    @IBOutlet weak var libraryIconInfo: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
