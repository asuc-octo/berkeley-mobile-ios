//
//  StudyGroupsView.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 10

/// View holding a CollectionView to display all the user's study groups
class StudyGroupsView: UIView {
    static let cellsPerRow = 2
    
    var studyGroups: [StudyGroup] = []
    /// viewcontroller that this view is in. used to present new view controllers
    var enclosingVC: UIViewController
    /// whether to add a "Create Preference" cell as the first cell
    var includeCreatePreference: Bool = false
    /// allows for dynamically resizing the collection view height to match the number of elements
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    private let collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(StudyGroupCell.self, forCellWithReuseIdentifier: StudyGroupCell.kCellIdentifier)
        collection.register(CreatePreferenceCell.self, forCellWithReuseIdentifier: CreatePreferenceCell.kCellIdentifier)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.allowsSelection = true
        
        collection.layer.masksToBounds = true
        collection.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collection.contentInsetAdjustmentBehavior = .never
        
        return collection
    }()
    
    public init(studyGroups: [StudyGroup], enclosingVC: UIViewController, includeCreatePreference: Bool = false) {
        self.enclosingVC = enclosingVC
        super.init(frame: .zero)
        
        self.studyGroups = studyGroups
        self.includeCreatePreference = includeCreatePreference
        
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
        collection.setContentOffset(CGPoint(x: -5, y: -5), animated: false)
        self.layoutIfNeeded()
    }
    
    public func refreshGroups() {
        // TODO: get groups again from backend
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
        return self.studyGroups.count + (includeCreatePreference ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && includeCreatePreference {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CreatePreferenceCell.kCellIdentifier, for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudyGroupCell.kCellIdentifier, for: indexPath)
            let index = indexPath.row - (includeCreatePreference ? 1 : 0)
            if let studyGroupCell = cell as? StudyGroupCell {
                if let group = studyGroups[safe: index] {
                    studyGroupCell.configure(studyGroup: group)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row - (includeCreatePreference ? 1 : 0)
        guard let group = studyGroups[safe: index] else { return }
        if group.pending {
            let vc = PendingGroupViewController()
            vc.presentSelf(presentingVC: enclosingVC, studyGroup: group)
        } else {
            // bring up group view
            print("group view")
        }
    }
}

/// Cell displaying information for a single study group
class StudyGroupCell: UICollectionViewCell {
    static let kCellIdentifier = "studyGroupCell"
    static let cellHeight = 81
    
    // MARK: UI Elements
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
        stack.spacing = -20
        return stack
    }()
    
    let pendingTag: TagView = {
        let tag = TagView()
        tag.text = "Pending"
        tag.backgroundColor = Color.pendingTag
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
    
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
        
        card.addSubview(classLabel)
        classLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        classLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12).isActive = true
        
        card.addSubview(profilePictureStack)
        profilePictureStack.heightAnchor.constraint(equalToConstant: 26).isActive = true
        profilePictureStack.leftAnchor.constraint(equalTo: card.leftAnchor, constant: kViewMargin).isActive = true
        profilePictureStack.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -1 * kViewMargin).isActive = true
        profilePictureStack.topAnchor.constraint(equalTo: classLabel.bottomAnchor, constant: 6).isActive = true
        profilePictureStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -1 * kViewMargin).isActive = true
        
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
            return
        }
        classLabel.alpha = 1
        pendingTag.isHidden = true
        profilePictureStack.isHidden = false
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
            
            // TODO: replace with single letter placeholder
            let placeholderView = UIView()
            placeholderView.backgroundColor = .red
            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.addSubview(placeholderView)
            placeholderView.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
            placeholderView.rightAnchor.constraint(equalTo: profileImageView.rightAnchor).isActive = true
            placeholderView.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
            placeholderView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
            
            profilePictureStack.addArrangedSubview(profileImageView)
            if let url = member.profilePictureURL {
                ImageLoader.shared.getImage(url: url) { result in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            profileImageView.image = image
                            member.profilePicture = image
                            placeholderView.isHidden = true
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        /* Allows for two types of profile picture stacking.
         If less than 4 elements: left align and 5 spacing between pictures.
         If 4 or more: equal spacing and allow for overlapping pictures.
         */
        if studyGroup.groupMembers.count < 4 {
            let filler = UIView()
            filler.setContentHuggingPriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
            filler.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
            profilePictureStack.addArrangedSubview(filler)
            profilePictureStack.distribution = .fill
            profilePictureStack.spacing = 5
        } else {
            profilePictureStack.distribution = .equalCentering
            profilePictureStack.spacing = -20
        }
    }
}

/// Cell allowing user to create a new group
class CreatePreferenceCell: UICollectionViewCell {
    static let kCellIdentifier = "createPreferenceCell"
    // MARK: UI Elements
    let createPreferencePlus: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let circleRadius: CGFloat = 9.5
        view.layer.cornerRadius = circleRadius
        view.backgroundColor = Color.StudyPact.StudyGroups.createPreferenceGreenPlus
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
    
    let createPreferenceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = Font.medium(16)
        label.alpha = 0.51
        label.text = "Create\nPreference"
        return label
    }()
    
    // MARK: Setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.cardBackground
        layer.cornerRadius = 12
        
        // dotted line border
        let bounds = contentView.bounds
        let layer = CAShapeLayer.init()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 12)
        layer.path = path.cgPath
        layer.strokeColor = Color.StudyPact.StudyGroups.createPreferenceDottedBorder.cgColor
        layer.lineDashPattern = [2, 2]
        layer.fillColor = nil
        contentView.layer.addSublayer(layer)
        
        let joinedView = UIView()
        joinedView.translatesAutoresizingMaskIntoConstraints = false
        joinedView.addSubview(createPreferencePlus)
        createPreferencePlus.centerYAnchor.constraint(equalTo: joinedView.centerYAnchor).isActive = true
        createPreferencePlus.leftAnchor.constraint(equalTo: joinedView.leftAnchor).isActive = true
        joinedView.addSubview(createPreferenceLabel)
        createPreferenceLabel.centerYAnchor.constraint(equalTo: joinedView.centerYAnchor).isActive = true
        createPreferenceLabel.leftAnchor.constraint(equalTo: createPreferencePlus.rightAnchor, constant: kViewMargin).isActive = true
        createPreferenceLabel.rightAnchor.constraint(equalTo: joinedView.rightAnchor).isActive = true
        
        contentView.addSubview(joinedView)
        joinedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        joinedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        setUpGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.goToCreatePreference(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func goToCreatePreference(_ sender: UITapGestureRecognizer) {
        print("Create Preference tapped")
        // TODO: go to create preference flow
    }
}

