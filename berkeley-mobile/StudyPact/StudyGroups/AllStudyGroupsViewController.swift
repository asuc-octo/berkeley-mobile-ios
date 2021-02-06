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
    var studyGroupsGrid: StudyGroupsView!
    
    
    // MARK: UI Elements
    let studyPactLabel: UILabel = {
        let label = UILabel()
        label.text = "Study Pact"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(30)
        return label
    }()
    
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
    
    private func setUpBackgroundView() {
        view.backgroundColor = Color.modalBackground
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
    }
    
    private func setUpElements() {
        view.addSubview(studyPactLabel)
        studyPactLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 2 * kViewMargin).isActive = true
        studyPactLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        studyPactLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        view.addSubview(card)
        card.topAnchor.constraint(equalTo: studyPactLabel.bottomAnchor, constant: kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: kViewMargin).isActive = true
        card.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        card.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -2 * kViewMargin).isActive = true
        
        card.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: kViewMargin).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -1 * kViewMargin).isActive = true
        
        studyGroupsGrid = StudyGroupsView(enclosingVC: self, limit: nil)
        studyGroupsGrid.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(studyGroupsGrid)
        studyGroupsGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: kViewMargin).isActive = true
        studyGroupsGrid.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        studyGroupsGrid.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        studyGroupsGrid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
    }
}
