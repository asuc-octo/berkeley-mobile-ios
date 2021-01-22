//
//  StudyPreferencesViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/22/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16
fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

class StudyPreferencesViewController: UIViewController {
    var studyGroups: [StudyGroup] = []
    private var tableHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        classesTable.dataSource = self
        classesTable.delegate = self
        setUpBackgroundView()
        setUpElements()
    }
    
    override func viewDidLayoutSubviews() {
        let height = classesTable.contentSize.height * 1.4
        tableHeightConstraint.constant = height
        self.view.layoutIfNeeded()
    }
    
    func setUpBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
    }
    
    func setUpElements() {
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: kViewMargin).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        view.addSubview(card)
        card.layoutMargins = kCardPadding
        card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        card.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        card.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
        card.addSubview(preferencesLabel)
        preferencesLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        preferencesLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        preferencesLabel.rightAnchor.constraint(lessThanOrEqualTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
//        let scheduleButton = UIButton()
//        scheduleButton.setTitle("See Full Schedule >", for: .normal)
//        scheduleButton.titleLabel?.font = Font.light(12)
//        scheduleButton.setTitleColor(Color.primaryText, for: .normal)
//        scheduleButton.setTitleColor(.black, for: .highlighted)
//        scheduleButton.addTarget(self, action: #selector(willExpandClasses), for: .touchUpInside)
//        card.addSubview(scheduleButton)
//        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
//        scheduleButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
//        scheduleButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
//        scheduleButton.leftAnchor.constraint(greaterThanOrEqualTo: headerLabel.rightAnchor, constant: 5).isActive = true
        
        card.addSubview(classesTable)
        classesTable.translatesAutoresizingMaskIntoConstraints = false
        classesTable.register(StudyPreferenceCell.self, forCellReuseIdentifier: StudyPreferenceCell.kCellIdentifier)
        classesTable.topAnchor.constraint(equalTo: preferencesLabel.bottomAnchor, constant: kViewMargin).isActive = true
        classesTable.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        classesTable.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        classesTable.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        tableHeightConstraint = classesTable.heightAnchor.constraint(equalToConstant: 120)
        tableHeightConstraint.priority = .defaultLow
        tableHeightConstraint.isActive = true
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Study Groups"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(30)
        return label
    }()
    
    let card: CardView = {
        let cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let preferencesLabel: UILabel = {
        let label = UILabel()
        label.text = "Update Preferences"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(24)
        return label
    }()
    
    let classesTable: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.rowHeight = EventTableViewCell.kCellHeight
        table.register(EventTableViewCell.self, forCellReuseIdentifier: GymClassesController.kCellIdentifier)
        return table
    }()
}

extension StudyPreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studyGroups.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StudyPreferenceCell.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudyPreferenceCell.kCellIdentifier, for: indexPath)
        if let cell = cell as? StudyPreferenceCell {
            cell.configure(group: studyGroups[indexPath.row])
        }
        return cell
    }
}

class StudyPreferenceCell: CardTableViewCell {
    static let kCellHeight: CGFloat = 60
    static let kCellIdentifier: String = "studyPreferenceCell"
    
    var group: StudyGroup?
    
    let classLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layoutMargins = kCardPadding
        contentView.addSubview(classLabel)
        classLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        classLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    func configure(group: StudyGroup) {
        classLabel.text = group.className
        self.group = group
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
