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
        let heightOfCellRatio = UIScreen.main.bounds.width / 375
        layout.itemSize = CGSize(width: width, height: Int(160 * heightOfCellRatio))
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
            groupMemberCell.configure(groupMember: studyGroupMembers[index], parentView: parentView)
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

/// Cell displaying information for members of a single study view
class GroupMemberCell: UICollectionViewCell {
    static let kCellIdentifier = "groupMemberCell"
    
    private var _member: StudyGroupMember!
    private var _parentView: UIViewController!
    private var profileRadius: CGFloat {
        get {
            return frame.width * 0.2
        }
    }
    
    // MARK: UI Elements
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.regular(12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    let avatar: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()

    var emailButton: QuickActionButton!
    var msgButton: QuickActionButton!
    var callButton: QuickActionButton!
    
    @objc func emailTapped() {
        UIPasteboard.general.string = _member.email
        _parentView.presentSuccessAlert(title: "Email copied to clipboard.")
    }
    
    @objc func msgTapped() {
        if _member.facebookUsername != nil {
            if let url = URL(string: "https://m.me/" + _member.facebookUsername!) {
                UIApplication.shared.open(url)
            }
        } else {
            _parentView.presentFailureAlert(title: "Failed to launch messenger", message: "This user did not input their facebook user name.")
        }
        
    }
    
    @objc func callTapped() {
        if _member.phoneNumber != nil {
            UIPasteboard.general.string = _member.phoneNumber
            _parentView.presentSuccessAlert(title: "Phone number copied to clipboard.")
        } else {
            _parentView.presentFailureAlert(title: "Failed to copy phone number", message: "This user did not input their phone number.")
        }
       
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
        nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: kViewMargin).isActive = true
        nameLabel.leftAnchor.constraint(greaterThanOrEqualTo: card.leftAnchor, constant: 5).isActive = true
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: card.rightAnchor, constant: 5).isActive = true
        
        card.addSubview(avatar)
        avatar.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        avatar.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -kViewMargin / 2).isActive = true
        avatar.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.4).isActive = true
        avatar.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.4).isActive = true
        avatar.layer.cornerRadius = profileRadius
        avatar.backgroundColor = UIColor.lightGray
        avatar.clipsToBounds = true
        avatar.layer.masksToBounds = true
        
        emailButton = QuickActionButton(iconImage: UIImage(named:"email"))
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emailButton)
        emailButton.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        emailButton.widthAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        emailButton.heightAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        emailButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
        emailButton.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)
        
        msgButton = QuickActionButton(iconImage: UIImage(named:"messenger"))
        msgButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(msgButton)
        msgButton.rightAnchor.constraint(equalTo: emailButton.leftAnchor, constant: -kViewMargin / 2).isActive = true
        msgButton.widthAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        msgButton.heightAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        msgButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
        msgButton.addTarget(self, action: #selector(msgTapped), for: .touchUpInside)
        
        callButton = QuickActionButton(iconImage: UIImage(named:"phone-studyPact"))
        callButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(callButton)
        callButton.leftAnchor.constraint(equalTo: emailButton.rightAnchor, constant: kViewMargin / 2).isActive = true
        callButton.widthAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        callButton.heightAnchor.constraint(equalToConstant: frame.width * 0.25).isActive = true
        callButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        
        //PLACEHOLDER CODE FOR PING BUTTON
        
//        let memberPingButton = RoundedActionButton(title: "Ping to Study", font: Font.regular(8), color: UIColor(red: 0.984, green: 0.608, blue: 0.557, alpha: 1), iconImage: UIImage(named: "studyGroupBell"), iconSize: 14, cornerRadius: 12, iconOffset: -30)
//        memberPingButton.translatesAutoresizingMaskIntoConstraints = false
//        card.addSubview(memberPingButton)
//        memberPingButton.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
//        memberPingButton.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
//        memberPingButton.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: kViewMargin).isActive = true
//        memberPingButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -kViewMargin).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(groupMember: StudyGroupMember, parentView: UIViewController) {
        _member = groupMember
        _parentView = parentView
        nameLabel.text = groupMember.name
        msgButton.isEnabled = _member.facebookUsername != nil
        callButton.isEnabled = _member.phoneNumber != nil
        
        let placeholderLetter = String(_member.name.first ?? "O").uppercased()
        let placeholderView = ProfileLabel(text: placeholderLetter, radius: profileRadius, fontSize: 25)
        avatar.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.leftAnchor.constraint(equalTo: avatar.leftAnchor).isActive = true
        placeholderView.rightAnchor.constraint(equalTo: avatar.rightAnchor).isActive = true
        placeholderView.topAnchor.constraint(equalTo: avatar.topAnchor).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: avatar.bottomAnchor).isActive = true
        if let url = groupMember.profilePictureURL {
            ImageLoader.shared.getImage(url: url) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.avatar.image = image
                        placeholderView.isHidden = true
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

class QuickActionButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            iconView.tintColor = isEnabled ? BMColor.StudyPact.StudyGroups.enabledButton :
                BMColor.StudyPact.StudyGroups.disabledButton
        }
    }

    private var iconView: UIImageView!

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

        iconView = UIImageView()
        if iconImage != nil {
            iconView.image = iconImage?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = BMColor.StudyPact.StudyGroups.enabledButton
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


