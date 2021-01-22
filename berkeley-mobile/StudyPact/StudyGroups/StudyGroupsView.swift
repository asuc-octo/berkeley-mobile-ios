//
//  StudyGroupsView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 10

class StudyGroupsView: UIView {
    static let cellsPerRow = 2
    
    var studyGroups: [StudyGroup] = []
    var includeCreateGroup: Bool = false
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(StudyGroupCell.self, forCellWithReuseIdentifier: StudyGroupCell.kCellIdentifier)
        collection.register(CreateGroupCell.self, forCellWithReuseIdentifier: CreateGroupCell.kCellIdentifier)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        
        collection.layer.masksToBounds = true
        collection.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collection.contentInsetAdjustmentBehavior = .never
        
        return collection
    }()
    
    public init(studyGroups: [StudyGroup], includeCreateGroup: Bool = false) {
        super.init(frame: .zero)
        
        self.studyGroups = studyGroups
        self.includeCreateGroup = includeCreateGroup
        
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
        let width = Int(collection.frame.width - 20) / StudyGroupsView.cellsPerRow
        layout.itemSize = CGSize(width: width, height: StudyGroupCell.cellHeight)
        layout.minimumLineSpacing = 10
        collection.collectionViewLayout = layout
        
        collection.reloadData()
        
        let height = collection.collectionViewLayout.collectionViewContentSize.height + 16
        collectionHeightConstraint.constant = height
        self.layoutIfNeeded()
    }
    
    public func updateGroups(studyGroups: [StudyGroup]) {
        self.studyGroups = studyGroups
        collection.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StudyGroupsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.studyGroups.count + (includeCreateGroup ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && includeCreateGroup {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupCell.kCellIdentifier, for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudyGroupCell.kCellIdentifier, for: indexPath)
            let index = indexPath.row - (includeCreateGroup ? 1 : 0)
            if let studyGroupCell = cell as? StudyGroupCell {
                if let group = studyGroups[safe: index] {
                    studyGroupCell.configure(studyGroup: group)
                }
            }
            return cell
        }
    }
}

class StudyGroupCell: UICollectionViewCell {
    static let kCellIdentifier = "studyGroupCell"
    static let cellHeight = 106
    
    let classLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.bold(18)
        return label
    }()
    
    let profilePictureStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = -10
        return stack
    }()
    
    let environmentTag: TagView = {
        let tag = TagView()
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
    let meetingTag: TagView = {
        let tag = TagView()
        tag.backgroundColor = Color.meetingFormatTag
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
    let pendingTag: TagView = {
        let tag = TagView()
        tag.text = "Pending"
        tag.backgroundColor = Color.pendingTag
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        card.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        card.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        card.addSubview(classLabel)
        classLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        classLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12).isActive = true
        
        card.addSubview(profilePictureStack)
        profilePictureStack.heightAnchor.constraint(equalToConstant: 26).isActive = true
        profilePictureStack.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        profilePictureStack.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        profilePictureStack.topAnchor.constraint(equalTo: classLabel.bottomAnchor, constant: 6).isActive = true
        
        contentView.addSubview(environmentTag)
        environmentTag.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        environmentTag.topAnchor.constraint(greaterThanOrEqualTo: profilePictureStack.bottomAnchor, constant: 10).isActive = true
        environmentTag.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        
        contentView.addSubview(meetingTag)
        meetingTag.leftAnchor.constraint(greaterThanOrEqualTo: environmentTag.rightAnchor, constant: 6).isActive = true
        meetingTag.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        meetingTag.topAnchor.constraint(equalTo: environmentTag.topAnchor).isActive = true
        meetingTag.bottomAnchor.constraint(equalTo: environmentTag.bottomAnchor).isActive = true
        
        contentView.addSubview(pendingTag)
        pendingTag.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        pendingTag.rightAnchor.constraint(lessThanOrEqualTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        pendingTag.topAnchor.constraint(greaterThanOrEqualTo: classLabel.bottomAnchor, constant: 10).isActive = true
        pendingTag.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(studyGroup: StudyGroup) {
        classLabel.text = studyGroup.className
        if studyGroup.pending {
            classLabel.alpha = 0.55
            pendingTag.isHidden = false
            profilePictureStack.isHidden = true
            meetingTag.isHidden = true
            environmentTag.isHidden = true
            return
        }
        pendingTag.isHidden = true
        profilePictureStack.isHidden = false
        meetingTag.isHidden = false
        environmentTag.isHidden = false
        
        if studyGroup.collaborative {
            environmentTag.text = "Collab"
            environmentTag.backgroundColor = Color.collabEnvironmentTag
        } else {
            environmentTag.text = "Solo"
            environmentTag.backgroundColor = Color.soloEnvironmentTag
        }
        profilePictureStack.removeAllArrangedSubviews()
        for var member in studyGroup.groupMembers {
            let profileImageView = UIImageView()
            profileImageView.image = UIImage(named: "Profile")
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.clipsToBounds = true
            let profileRadius: CGFloat = 13
            profileImageView.layer.cornerRadius = profileRadius
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.widthAnchor.constraint(equalToConstant: 2 * profileRadius).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 2 * profileRadius).isActive = true
            
            profilePictureStack.addArrangedSubview(profileImageView)
            if let url = member.profilePictureURL {
                ImageLoader.shared.getImage(url: url) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            profileImageView.image = image
                            member.profilePicture = image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        if studyGroup.groupMembers.count < 4 {
            let filler = UIView()
            filler.setContentHuggingPriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
            filler.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
            profilePictureStack.addArrangedSubview(filler)
            profilePictureStack.distribution = .fill
            profilePictureStack.spacing = 5
        } else {
            profilePictureStack.distribution = .equalCentering
            profilePictureStack.spacing = -10
        }
        if studyGroup.virtual {
            meetingTag.text = "Virtual"
        } else {
            meetingTag.text = "In Person"
        }
    }
}

class CreateGroupCell: UICollectionViewCell {
    static let kCellIdentifier = "createGroupCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.cardBackground
        layer.cornerRadius = 12
        
        let bounds = contentView.bounds
        let layer = CAShapeLayer.init()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 12)
        layer.path = path.cgPath
        layer.strokeColor = Color.StudyGroups.createGroupDottedBorder.cgColor
        layer.lineDashPattern = [2, 2]
        layer.fillColor = nil
        contentView.layer.addSublayer(layer)
        
        let joinedView = UIView()
        joinedView.translatesAutoresizingMaskIntoConstraints = false
        joinedView.addSubview(createGroupPlus)
        createGroupPlus.centerYAnchor.constraint(equalTo: joinedView.centerYAnchor).isActive = true
        createGroupPlus.leftAnchor.constraint(equalTo: joinedView.leftAnchor).isActive = true
        joinedView.addSubview(createGroupLabel)
        createGroupLabel.centerYAnchor.constraint(equalTo: joinedView.centerYAnchor).isActive = true
        createGroupLabel.leftAnchor.constraint(equalTo: createGroupPlus.rightAnchor, constant: kViewMargin).isActive = true
        createGroupLabel.rightAnchor.constraint(equalTo: joinedView.rightAnchor).isActive = true
        
        contentView.addSubview(joinedView)
        joinedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        joinedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        setUpGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let createGroupPlus: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let circleRadius: CGFloat = 9.5
        view.layer.cornerRadius = circleRadius
        view.backgroundColor = Color.StudyGroups.createGroupGreenPlus
        view.widthAnchor.constraint(equalToConstant: 2 * circleRadius).isActive = true
        view.heightAnchor.constraint(equalToConstant: 2 * circleRadius).isActive = true
        
        let plus = UILabel()
        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.text = "+"
        plus.textColor = UIColor.white
        plus.font = Font.medium(16)
        view.addSubview(plus)
        plus.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plus.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    let createGroupLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = Font.medium(16)
        label.alpha = 0.51
        label.text = "Create\nGroup"
        return label
    }()
    
    private func setUpGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.goToCreateGroup(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func goToCreateGroup(_ sender: UITapGestureRecognizer) {
        print("Create Group tapped")
        // TODO: go to create group flow
    }
}

