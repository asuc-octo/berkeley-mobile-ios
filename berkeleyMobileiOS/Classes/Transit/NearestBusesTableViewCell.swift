//
//  NearestBusesTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 3/5/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class NearestBusesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var timesCollection: UICollectionView!
    @IBOutlet var busName: UILabel!
    @IBOutlet var busLabel: UILabel!
    var nearestBus: nearestBus?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! timeCell
        cell.time.text = nearestBus?.timeLeft[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedBus = nearestBus {
            return selectedBus.timeLeft.count
        } else {
            return 0
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
