//
//  StudyGroupDetailsViewController.swift
//  berkeley-mobile
//
//  Created by Patrick Cui on 1/23/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class StudyGroupDetailsViewController: UIViewController {
    
    var _studyGroup: StudyGroup!
    var groupMembersGrid: GroupMembersView!

    
    @objc func pingAll() {
        //TODO: ping all members of the study group
    }
    
    @objc func leaveGroup() {
        StudyPact.shared.leaveGroup(groupId: _studyGroup.id) { success in
            if success {
                self.presentSuccessAlert(title: "Successfully left group")
            } else {
                self.presentFailureAlert(title: "Failed to leave group", message: "There was an error. Please try again later.")
            }
        }
    }
    
    let card: CardView = {
        let cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(24)
        return label
    }()
    
    var pingAllButton: RoundedActionButton = {
        let button = RoundedActionButton(title: "Ping for Group Study", color: UIColor(red: 0.866, green: 0.264, blue: 0.264, alpha: 1), iconImage: UIImage(named: "studyGroupBell"), iconSize: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pingAll), for: .touchUpInside)
        return button
    }()
    
    var leaveGroupButton: RoundedActionButton = {
        let button = RoundedActionButton(title: "Leave Study Group", color: UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 1), iconImage: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(leaveGroup), for: .touchUpInside)
        return button
    }()
    
    func setUpBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
    }
    
    func setUpElements() {
        view.addSubview(card)
        card.topAnchor.constraint(equalTo: self.view.topAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        card.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        card.addSubview(titleLabel)
        titleLabel.text = _studyGroup.className
        titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: kViewMargin).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        groupMembersGrid = GroupMembersView(studyGroupMembers: _studyGroup.groupMembers, parentView: self)
        groupMembersGrid.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(groupMembersGrid)
        groupMembersGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kViewMargin).isActive = true
        groupMembersGrid.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        groupMembersGrid.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        groupMembersGrid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        
        view.addSubview(pingAllButton)
        pingAllButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: kViewMargin).isActive = true
        pingAllButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        pingAllButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kViewMargin).isActive = true
        pingAllButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
        view.addSubview(leaveGroupButton)
        leaveGroupButton.topAnchor.constraint(equalTo: pingAllButton.bottomAnchor, constant: kViewMargin / 2).isActive = true
        leaveGroupButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        leaveGroupButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kViewMargin).isActive = true
        leaveGroupButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackgroundView()
        setUpElements()
    }
    

}
