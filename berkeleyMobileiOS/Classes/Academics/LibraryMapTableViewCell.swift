//
//  LibraryMapTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh on 4/23/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps
class LibraryMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
