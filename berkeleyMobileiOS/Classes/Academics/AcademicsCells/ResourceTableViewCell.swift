//
//  ResourceTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 3/2/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

protocol ResourceCellDelegate {
    func reloadTableView()
}

class ResourceTableViewCell: UITableViewCell, ToggleButtonDelegate {

    var delegate: ResourceCellDelegate?
    var library: Library!
    
    @IBOutlet weak var favoriteButton: UIButton!
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
    
    // ========================================
    // MARK: - ToggleButtonDelegate
    // ========================================
    /**
     * When the favoriteButton is toggled, update the FavoriteStore.
     *
     * - Note:
     *  Ideally updating the Store should be done in a controller,
     *  but because that requires an extra layer of delegation/callback,
     *  opted to include the Store write action here.
     */
    func buttonDidToggle(_ button: ToggleButton) {
        library.isFavorited = button.isSelected
        FavoriteStore.shared.update(library)
        // Update Analytics
        if let vc = delegate {
            vc.reloadTableView()
        }
    }
}
