//
//  FitnessViewController.swift
//  bm-persona
//
//  Created by Kevin Hu on 11/21/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class FitnessViewController: UIViewController {
    
    static let kHeaderFont: UIFont = Font.bold(24)
    static let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    static let kViewMargin: CGFloat = 16
    
    private var scrollView: UIScrollView!
    private var content: UIView!
    
    private var upcomingCard: CardView!
    private var todayCard: CardView!
    private var gymCard: CardView!
    
    private var gyms: [Gym]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        setupScrollView()
        setupUpcomingClasses()
        setupTodayClasses()
        setupGyms()
        
        DataManager.shared.fetch(source: GymDataSource.self) { gyms in
            self.gyms = gyms as? [Gym] ?? []
            
        }
    }
    
    @objc func willExpandClasses() {
        UIView.animate(withDuration: 0.2) {
            self.todayCard.heightConstraint?.constant = self.view.frame.height
            self.todayCard.heightConstraint?.constant -=  self.view.layoutMargins.top + self.view.layoutMargins.bottom
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.todayCard.frame.minY)
            self.scrollView.contentOffset.y -= self.view.layoutMargins.top
            self.view.layoutIfNeeded()
            self.viewDidLayoutSubviews()
        }
    }
    
}

// MARK: - View

extension FitnessViewController {
    
    // ScrollView
    func setupScrollView() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setConstraintsToView(top: view, bottom: view, left: view, right: view)
        
        content = UIView()
        scrollView.addSubview(content)
        content.layoutMargins = view.layoutMargins
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = gymCard.frame.maxY + view.layoutMargins.bottom
    }
    
    // Upcoming Classes
    func setupUpcomingClasses() {
        let card = CardView()
        card.layoutMargins = FitnessViewController.kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: content.layoutMarginsGuide.topAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let contentView = UIView()
        contentView.layer.masksToBounds = true
        card.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setConstraintsToView(top: card, bottom: card, left: card, right: card)
        
        let headerLabel = UILabel()
        headerLabel.font = FitnessViewController.kHeaderFont
        headerLabel.text = "Upcoming Classes"
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        let collectionView = CardCollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: card.layoutMargins.left, bottom: 0, right: card.layoutMargins.right)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: FitnessViewController.kViewMargin).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: CardCollectionViewCell.kCardSize.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        
        collectionView.bottomAnchor.constraint(equalTo: card.layoutMarginsGuide.bottomAnchor).isActive = true
        upcomingCard = card
    }
    
    // Upcoming Classes
    func setupTodayClasses() {
        let card = CardView()
        card.layoutMargins = FitnessViewController.kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: upcomingCard.bottomAnchor, constant: FitnessViewController.kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        let headerLabel = UILabel()
        headerLabel.font = FitnessViewController.kHeaderFont
        headerLabel.text = "Today's Classes"
        card.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.topAnchor.constraint(equalTo: card.layoutMarginsGuide.topAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: card.layoutMarginsGuide.leftAnchor).isActive = true
        
        let scheduleButton = UIButton()
        scheduleButton.setTitle("See Full Schedule >", for: .normal)
        scheduleButton.titleLabel?.font = Font.thin(12)
        scheduleButton.setTitleColor(Color.primaryText, for: .normal)
        // TODO: Set color
        scheduleButton.setTitleColor(.black, for: .highlighted)
        scheduleButton.addTarget(self, action: #selector(willExpandClasses), for: .touchUpInside)
        card.addSubview(scheduleButton)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
        scheduleButton.rightAnchor.constraint(equalTo: card.layoutMarginsGuide.rightAnchor).isActive = true
        
        todayCard = card
    }
    
    // Gyms
    func setupGyms() {
        let card = CardView()
        card.layoutMargins = FitnessViewController.kCardPadding
        scrollView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: todayCard.bottomAnchor, constant: FitnessViewController.kViewMargin).isActive = true
        card.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        card.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor).isActive = true
        
        gymCard = card
    }
    
}

// MARK: - UICollectionViewDelegate

// Dummy Data
extension FitnessViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionView.kCellIdentifier, for: indexPath)
        if let card = cell as? CardCollectionViewCell {
            card.title.text = "Mat Pilates"
            card.subtitle.text = "Nov 10 / 1:00 PM"
            card.badge.text = "Core"
            card.badge.backgroundColor = .orange
        }
        return cell
    }
    
}
