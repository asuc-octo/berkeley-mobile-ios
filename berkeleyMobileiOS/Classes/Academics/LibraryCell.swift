//
//  LibraryCell.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 11/20/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class LibraryCell: UITableViewCell {
    
    @IBOutlet var libraryName: UILabel!
    @IBOutlet var libraryStatus: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
