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
    
    @IBOutlet weak var favorited: UIButton!
    
    var lib: Library!
    
    
    @IBAction func updateFavorites(sender:UIButton) {
        if (lib.isFavorited == false) {
            // Now need to make it favorited + change image
            lib.isFavorited = true
            favorited.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
        } else {
            lib.isFavorited = false
            favorited.setImage(#imageLiteral(resourceName: "heart_empty"), for: .normal)
        }
    }
    
    func updateUserFav(favData: [Library], index: Int) -> [Library]{
        let defaults = UserDefaults.standard
        var updatedData = favData
        if (lib.isFavorited) {
            updatedData.append(lib)
            
        } else {
            updatedData.remove(at: index)
        }
        
        defaults.set(updatedData, forKey:"favoritedLibraries")
        return updatedData
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
