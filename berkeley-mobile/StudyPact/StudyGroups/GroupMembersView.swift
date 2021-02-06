//
//  GroupMembersView.swift
//  berkeley-mobile
//
//  Created by Patrick Cui on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 10

/// View holding a CollectionView to display all members of the input study group
class GroupMembersView: UIView {
    static let cellsPerRow = 2
    var studyGroupMembers: [StudyGroupMember] = []
    var parentView: UIViewController = UIViewController()
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(GroupMemberCell.self, forCellWithReuseIdentifier: GroupMemberCell.kCellIdentifier)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        
        collection.layer.masksToBounds = true
        collection.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collection.contentInsetAdjustmentBehavior = .never
        
        return collection
    }()
    
    public init(studyGroupMembers: [StudyGroupMember], parentView: UIViewController) {
        super.init(frame: .zero)
        
        self.studyGroupMembers = studyGroupMembers
        self.parentView = parentView
        
        collection.delegate = self
        collection.dataSource = self
        self.addSubview(collection)
        collection.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collection.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionHeightConstraint = collection.heightAnchor.constraint(equalToConstant: 120)
        collectionHeightConstraint.priority = .defaultLow
        collectionHeightConstraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let width = Int(collection.frame.width - 20) / GroupMembersView.cellsPerRow
        layout.itemSize = CGSize(width: width, height: GroupMemberCell.cellHeight)
        layout.minimumLineSpacing = 10
        collection.collectionViewLayout = layout
        
        collection.reloadData()
        
        let height = collection.collectionViewLayout.collectionViewContentSize.height + 16
        collectionHeightConstraint.constant = height
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupMembersView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.studyGroupMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupMemberCell.kCellIdentifier, for: indexPath)
        let index = indexPath.row
        if let groupMemberCell = cell as? GroupMemberCell {
            groupMemberCell.configure(groupMember: studyGroupMembers[index])
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

/// Cell displaying information for a single study group
class GroupMemberCell: UICollectionViewCell {
    static let kCellIdentifier = "groupMemberCell"
    static let cellHeight = 180
    
    private var _member: StudyGroupMember!
    
    // MARK: UI Elements
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(12)
        return label
    }()
    
    let avatar: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    @objc func emailTapped() {
        //TODO: access the email address by calling _member.email
    }
    
    @objc func msgTapped() {
        //TODO: access group member info from _member
    }
    
    @objc func callTapped() {
        
    }
    
    // MARK: Setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        card.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor).isActive = true
        
        card.addSubview(avatar)
        avatar.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        avatar.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -kViewMargin / 2).isActive = true
        avatar.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.36).isActive = true
        avatar.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.36).isActive = true
        avatar.layer.cornerRadius = (frame.width * 0.36) / 2
        avatar.backgroundColor = UIColor.lightGray
        avatar.clipsToBounds = true
        avatar.layer.masksToBounds = true
        
        
        let emailButton = QuickActionButton(iconImage: UIImage(named:"email"))
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emailButton)
        emailButton.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        emailButton.widthAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        emailButton.heightAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        emailButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin / 2).isActive = true
        emailButton.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)
        
        let msgButton = QuickActionButton(iconImage: UIImage(named:"messenger"))
        msgButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(msgButton)
        msgButton.rightAnchor.constraint(equalTo: emailButton.leftAnchor, constant: -kViewMargin / 2).isActive = true
        msgButton.widthAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        msgButton.heightAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        msgButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin / 2).isActive = true
        msgButton.addTarget(self, action: #selector(msgTapped), for: .touchUpInside)
        
        let callButton = QuickActionButton(iconImage: UIImage(named:"phone-studyPact"))
        callButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(callButton)
        callButton.leftAnchor.constraint(equalTo: emailButton.rightAnchor, constant: kViewMargin / 2).isActive = true
        callButton.widthAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        callButton.heightAnchor.constraint(equalToConstant: frame.width * 0.2).isActive = true
        callButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin / 2).isActive = true
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        
        let memberPingButton = RoundedActionButton(title: "Ping to Study", font: Font.regular(8), color: UIColor(red: 0.984, green: 0.608, blue: 0.557, alpha: 1), iconImage: UIImage(named: "studyGroupBell"), iconSize: 14, cornerRadius: 12, iconOffset: -30)
        memberPingButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(memberPingButton)
        memberPingButton.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
        memberPingButton.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
        memberPingButton.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: kViewMargin).isActive = true
        memberPingButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -kViewMargin).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(groupMember: StudyGroupMember) {
        _member = groupMember
        nameLabel.text = groupMember.name
        if let url = groupMember.profilePictureURL {
            ImageLoader.shared.getImage(url: url) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.avatar.image = image
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}



class QuickActionButton: UIButton {

    init(iconImage: UIImage?) {
        super.init(frame: .zero)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        backgroundColor = UIColor(red: 0.692, green: 0.687, blue: 0.687, alpha: 0.24)

        // Set rounded corners and drop shadow
        layer.cornerRadius = 4
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        if iconImage != nil {
            let iconView = UIImageView()
            iconView.image = iconImage
            iconView.contentMode = .scaleAspectFit
            addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            iconView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
            iconView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        }

        
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


