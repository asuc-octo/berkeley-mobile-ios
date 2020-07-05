//
//  CollapsibleCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class CollapsibleCardView: CardView {
    var collapsedView: UIView!
    var openedView: UIView!
    var isOpen: Bool!
    var openedAction: (() -> Void)?
    var leftIcon: UIImageView?
    
    var collapsedConstraint: NSLayoutConstraint!
    var openConstraint: NSLayoutConstraint!
    
    public init() {
        super.init(frame: CGRect.zero)
    }
    
    public func setContents(collapsedView: UIView, openedView: UIView, isOpen: Bool = false, openedAction: (() -> Void)? = nil, leftIcon: UIImageView? = nil) {
        self.collapsedView = collapsedView
        self.openedView = openedView
        self.isOpen = isOpen
        self.openedAction = openedAction
        self.leftIcon = leftIcon
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        setUpViews()
        setUpGestures()
    }
    
    func setUpGestures() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        toggleState()
        if let openedAction = openedAction {
            openedAction()
        }
    }
    
    func setUpViews() {
        self.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        
        containerView.addSubview(chevronIcon)
        containerView.addSubview(collapsedView)
        containerView.addSubview(openedView)
        
        chevronIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        chevronIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        chevronIcon.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        chevronIcon.centerYAnchor.constraint(equalTo: collapsedView.centerYAnchor).isActive = true
        
        var leftConstraint = collapsedView.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor)
        if let leftIcon = leftIcon {
            self.addSubview(leftIcon)
            leftIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
            leftIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
            leftIcon.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            leftIcon.centerYAnchor.constraint(equalTo: collapsedView.centerYAnchor).isActive = true
            leftConstraint = collapsedView.leftAnchor.constraint(equalTo: leftIcon.rightAnchor, constant: kViewMargin)
        }
        
        collapsedView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        collapsedView.rightAnchor.constraint(equalTo: chevronIcon.leftAnchor, constant: -1 * kViewMargin).isActive = true
        leftConstraint.isActive = true
        
        openedView.leftAnchor.constraint(equalTo: collapsedView.leftAnchor).isActive = true
        openedView.topAnchor.constraint(equalTo: collapsedView.bottomAnchor, constant: kViewMargin).isActive = true
        openedView.rightAnchor.constraint(equalTo: collapsedView.rightAnchor).isActive = true
        
        collapsedConstraint = collapsedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        openConstraint = openedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        setState(opened: isOpen)
    }
    
    func toggleState() {
        setState(opened: !isOpen)
        if isOpen {
            chevronIcon.transform = chevronIcon.transform.rotated(by: -1 * .pi / 2)
        } else {
            chevronIcon.transform = chevronIcon.transform.rotated(by: .pi / 2)
        }
    }
    
    func setState(opened: Bool) {
        if opened {
            collapsedConstraint.isActive = false
            openConstraint.isActive = true
        } else {
            openConstraint.isActive = false
            collapsedConstraint.isActive = true
        }
        self.layoutIfNeeded()
        isOpen = opened
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let chevronIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Back")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
}
