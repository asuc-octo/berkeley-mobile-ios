//
//  StudyGroupDetailsViewController.swift
//  berkeley-mobile
//
//  Created by Patrick Cui on 1/23/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class StudyGroupDetailsViewController: UIViewController {
    
    var _studyGroup: StudyGroup!
    var groupMembersGrid: GroupMembersView!
    
    @objc func pingAll() {
        //TODO: ping all members of the study group
    }
    
    @objc func leaveGroup() {
        let alertController = AlertView(headingText: "Leave Study Group", messageText: "Would you like to leave your study group for \(_studyGroup.className)?", action1Label: "Cancel", action1Color: BMColor.AlertView.secondaryButton, action1Completion: {
            self.dismiss(animated: true, completion: nil)
        }, action2Label: "Yes", action2Color: BMColor.ActionButton.background, action2Completion: {
            StudyPact.shared.leaveGroup(group: self._studyGroup) { success in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.presentFailureAlert(title: "Failed to Leave Group", message: "There was an error. Please try again later.")
                }
            }
        }, withOnlyOneAction: false)
        self.present(alertController, animated: true, completion: nil)
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
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    var pingAllButton: RoundedActionButton = {
        let button = RoundedActionButton(title: "Ping for Group Study", color: UIColor(red: 0.866, green: 0.264, blue: 0.264, alpha: 1), iconImage: UIImage(named: "studyGroupBell"), iconSize: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pingAll), for: .touchUpInside)
        return button
    }()
    
    var leaveGroupButton: RoundedActionButton = {
        let button = RoundedActionButton(title: "Leave Study Group", color: UIColor.lightGray, iconImage: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(leaveGroup), for: .touchUpInside)
        return button
    }()
    
    func setUpBackgroundView() {
        view.backgroundColor = BMColor.modalBackground
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
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        groupMembersGrid = GroupMembersView(studyGroupMembers: _studyGroup.groupMembers, parentView: self)
        groupMembersGrid.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(groupMembersGrid)
        groupMembersGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kViewMargin).isActive = true
        groupMembersGrid.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        groupMembersGrid.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        groupMembersGrid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        
        //PLACEHOLDER CODE FOR PING BUTTON
        
//        //view.addSubview(pingAllButton)
//        pingAllButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: kViewMargin).isActive = true
//        pingAllButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -1 * kViewMargin).isActive = true
//        pingAllButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kViewMargin).isActive = true
//        pingAllButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
        view.addSubview(leaveGroupButton)
        leaveGroupButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: kViewMargin).isActive = true
        leaveGroupButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        leaveGroupButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: kViewMargin).isActive = true
        leaveGroupButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackgroundView()
        setUpElements()
    }
    
    public func presentSelf(presentingVC: UIViewController, studyGroup: StudyGroup) {
        self._studyGroup = studyGroup
        presentingVC.present(self, animated: true, completion: nil)
    }
}
extension StudyGroupDetailsViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_one_study_group", parameters: nil)
    }
}
