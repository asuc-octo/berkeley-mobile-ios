//
//  AllStudyGroupsViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

/// Expanded page showing all study groups in a larger CollectionView
class AllStudyGroupsViewController: UIViewController {
    var studyGroups: [StudyGroup] = []
    var studyGroupsGrid: StudyGroupsView!
    
    // MARK: UI Elements
    let card: CardView = {
        let cardView = CardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Study Groups"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(24)
        return label
    }()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpBackgroundView()
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        studyGroupsGrid.refreshGroups()
    }
    
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
        titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: kViewMargin).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        studyGroupsGrid = StudyGroupsView(studyGroups: studyGroups, includeCreatePreference: true)
        studyGroupsGrid.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(studyGroupsGrid)
        studyGroupsGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kViewMargin).isActive = true
        studyGroupsGrid.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        studyGroupsGrid.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        studyGroupsGrid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
    }
}
