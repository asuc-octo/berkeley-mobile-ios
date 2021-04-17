//
//  PendingGroupViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/29/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

fileprivate let kViewMargin: CGFloat = 16

class PendingGroupViewController: UIViewController {
    var studyGroup: StudyGroup!
    
    // MARK: UI Elements
    let classLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(30)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    let card: CardView = {
        let cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Match Pending"
        label.textColor = Color.StudyPact.StudyGroups.pendingLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(24)
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove Pending Request", for: .normal)
        button.backgroundColor = Color.StudyPact.StudyGroups.leaveGroupButton
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Font.medium(12)
        let radius: CGFloat = 20
        button.layer.cornerRadius = radius
        button.addTarget(self, action: #selector(removeRequest), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpBackgroundView()
        setUpElements()
    }
    
    private func setUpBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
    }
    
    private func setUpElements() {
        classLabel.text = studyGroup.className
        
        view.addSubview(classLabel)
        classLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 2 * kViewMargin).isActive = true
        classLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        classLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        view.addSubview(card)
        card.topAnchor.constraint(equalTo: classLabel.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        card.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        card.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
        card.addSubview(pendingLabel)
        pendingLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: kViewMargin).isActive = true
        pendingLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        pendingLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        card.addSubview(removeButton)
        removeButton.topAnchor.constraint(equalTo: pendingLabel.bottomAnchor, constant: kViewMargin).isActive = true
        removeButton.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        removeButton.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        removeButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
    }
    
    @objc func removeRequest() {
        let alertController = UIAlertController(title: "Remove Pending Request", message: "Would you like to remove your pending request to join a study group for \(studyGroup.className)?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { _ in
            StudyPact.shared.cancelPending(group: self.studyGroup) { success in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.presentFailureAlert(title: "Unable to Remove", message: "An issue occurred when attempting to remove your pending request. Please try again later.")
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func presentSelf(presentingVC: UIViewController, studyGroup: StudyGroup) {
        self.studyGroup = studyGroup
        presentingVC.present(self, animated: true, completion: nil)
    }
}
extension PendingGroupViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_pending_group_invite", parameters: nil)
    }
}
