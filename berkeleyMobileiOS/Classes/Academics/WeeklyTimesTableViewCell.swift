//
//  WeeklyTimesTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Marisa Wong on 4/15/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

class WeeklyTimesTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var day: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var expandButton: UIButton!
    
    @IBOutlet weak var timeTableView: UITableView!
    
    @IBAction func expand(_ sender: Any) {
        
        
    }
    
    
    
    
    var days: [String]!
    var times: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        timeTableView.dataSource = self
        timeTableView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


extension WeeklyTimesTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timeTableView.dequeueReusableCell(withIdentifier: "timeCell", for:indexPath) as! TimeTableViewCell
        cell.day.text = days![indexPath.row]
        cell.time.text = times![indexPath.row]
        return cell
    }
    
}

