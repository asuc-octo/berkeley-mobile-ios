//
//  DiningLegendView.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Bunarjo on 10/29/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit

/**
 * The view that displays all the possible types of restrictions that can appear
 * in a dining hall. Note that it will not display the restrictions that are not
 * at the dining hall.
 */
class DiningLegendView: UIView, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    private let diningTableViewCellIdentifier = "DiningTableViewCellIdentifier"
    let model = DiningLegendModel()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.delegate = self
        tv.dataSource = self
        tv.bounces = false
        tv.backgroundColor = .lightGray
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        backgroundColor = .lightGray
        tableView.register(DiningLegendTableViewCell.self, forCellReuseIdentifier: diningTableViewCellIdentifier)
        
        addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func reloadRestrictions() {
        tableView.reloadData()
    }
    
    // ===================================================
    // MARK: - UITableViewDataSource & UITableViewDelegate
    // ===================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRestrictionsToDisplay()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: diningTableViewCellIdentifier, for: indexPath) as! DiningLegendTableViewCell
        cell.backgroundColor = DiningLegendModel.Constants.cellColor
        cell.selectionStyle = .none
        cell.restrictionImage.image = model.getImageToDisplay(atIndex: indexPath.row)
        cell.restrictionLabel.text = model.getRestrictionToDisplay(atIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningLegendModel.Constants.restrictionCellHeight
    }
}
