//
//  RecentAlertsTableViewController.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 4/21/23.
//  Copyright © 2023 ASUC OCTO. All rights reserved.
//

import UIKit

class RecentAlertsTableViewController: CardView {

    private let headerLabel = UILabel()
    private let recentAlertsTableView = UITableView()
    
    init() {
        super.init(frame: .zero)
        configureBackgroundCard()
        configureRecentAlertsTableView()
        configureContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBackgroundCard() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        headerLabel.text = "Recent Alerts"
        headerLabel.font = Font.bold(24)
        headerLabel.textAlignment = .left
        headerLabel.textColor = Color.blackText
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.7
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
    }
    
    private func configureRecentAlertsTableView() {
        addSubview(recentAlertsTableView)
        recentAlertsTableView.translatesAutoresizingMaskIntoConstraints = false
        recentAlertsTableView.delegate = self
        recentAlertsTableView.dataSource = self
        recentAlertsTableView.register(RecentAlertCell.self, forCellReuseIdentifier: RecentAlertCell.reuseID)
    }
    
    private func configureContraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo:
                self.layoutMarginsGuide.leadingAnchor),
            headerLabel.rightAnchor.constraint(equalTo:
                self.layoutMarginsGuide.rightAnchor),
        ])
    }
}

extension RecentAlertsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentAlertsTableView.dequeueReusableCell(withIdentifier: RecentAlertCell.reuseID) as! RecentAlertCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10.0
    }
}

class RecentAlertCell: UITableViewCell {
    static let reuseID = "RecentAlertCell"
    private var cardView: CardView!
    private var containerView: UIView!
    private var typeColorView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.setConstraintsToView(top: self, bottom: self, left: self, right: self)
        self.addSubview(cardView)
        
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.masksToBounds = true
        containerView.setConstraintsToView(top: backgroundView, bottom: backgroundView, left: backgroundView, right: backgroundView)
        containerView.backgroundColor = .blue
        cardView.addSubview(containerView)
        
        typeColorView = UIView()
        typeColorView.translatesAutoresizingMaskIntoConstraints = false
        typeColorView.setConstraintsToView(top: containerView, bottom: containerView, left: containerView)
        typeColorView.setWidthConstraint(10)
        typeColorView.backgroundColor = UIColor.yellow
        containerView.addSubview(typeColorView)
    }
}
