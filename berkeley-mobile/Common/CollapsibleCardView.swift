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

/// Generalized card view that can collapse and expand when touched.
class CollapsibleCardView: CardView {
    /// view to show when collapsed
    private var collapsedView: UIView!
    /// view to show below collapsedView when opened
    private var openedView: UIView!
    private var isOpen: Bool!
    /// any actions to be taken when the card opens/closes
    public var toggleAction: ((_ open: Bool) -> Void)?
    /// any actions to be taken after the card has finished opening/closing
    public var toggleCompletionAction: ((_ open: Bool) -> Void)?
    /// icon to display to the left of the collapsedView
    private var leftIcon: UIImageView?
    /// view to call layoutIfNeeded() on to animate open/close; must be parent view containing all subviews which will be adjusted to prevent 'jumping'
    public var animationView: UIView!
    
    public init() {
        super.init(frame: CGRect.zero)
    }
    
    public func setContents(collapsedView: UIView, openedView: UIView, animationView: UIView, isOpen: Bool = false, toggleAction: ((Bool) -> Void)? = nil, toggleCompletionAction: ((Bool) -> Void)? = nil, leftIcon: UIImageView? = nil) {
        self.collapsedView = collapsedView
        self.openedView = openedView
        self.animationView = animationView
        self.isOpen = isOpen
        self.toggleAction = toggleAction
        self.toggleCompletionAction = toggleCompletionAction
        self.leftIcon = leftIcon
        self.layoutMargins = kCardPadding
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        setUpViews()
        setUpGestures()
    }
    
    /// Sets up gesture recognizer so the card opens/closes when any part of the card is tapped
    private func setUpGestures() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        toggleAction?(!self.isOpen)
        toggleState() {
            self.toggleCompletionAction?(self.isOpen)
        }
    }
    
    private func setUpViews() {
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
        
        // constrain the collapsedView to icon or the left of the card if no icon
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
        collapsedView.heightAnchor.constraint(greaterThanOrEqualTo: chevronIcon.heightAnchor).isActive = true
        leftConstraint.isActive = true
        
        openedView.leftAnchor.constraint(equalTo: collapsedView.leftAnchor).isActive = true
        openedView.topAnchor.constraint(equalTo: collapsedView.bottomAnchor, constant: kViewMargin).isActive = true
        openedView.rightAnchor.constraint(equalTo: collapsedView.rightAnchor).isActive = true
        
        self.layoutIfNeeded()
        setState(opened: isOpen)
    }
    
    /// Open or close the card and rotate the chevron
    private func toggleState(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.setState(opened: !self.isOpen)
            if self.isOpen {
                self.chevronIcon.transform = self.chevronIcon.transform.rotated(by: -1 * .pi / 2)
            } else {
                self.chevronIcon.transform = self.chevronIcon.transform.rotated(by: .pi / 2)
            }
        }) { _ in
            completion?()
        }
    }
    
    private func setState(opened: Bool) {
        if opened {
            containerView.setHeightConstraint(openedView.frame.maxY)
        } else {
            containerView.setHeightConstraint(collapsedView.frame.maxY)
        }
        animationView.layoutIfNeeded()
        isOpen = opened
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// contains all contents of the collapsible card. this is necessary because clipsToBounds must be true to open/close successfully, but setting it to true for the entire view would get rid of the shadows on the card view.
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let chevronIcon: UIImageView = {
        let img = UIImageView()
        img.tintColor = .label
        img.contentMode = .scaleAspectFit
        img.image = UIImage(systemName: "chevron.left")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
}
