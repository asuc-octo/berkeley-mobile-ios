//
//  RoommateViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 4/17/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

fileprivate let kViewMargin: CGFloat = 16

class RoommateViewController: UIViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SignInManager.shared.addDelegate(delegate: self)
    }
    
    override func loadView() {
        super.loadView()
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        setUpRoommateCard()
        setupActionButtons()
    }
    
    var roommateCard: CardView = CardView()
    let roommateContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setUpRoommateCard() {
        roommateCard = CardView()
        roommateCard.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        self.view.addSubview(roommateCard)
        roommateCard.translatesAutoresizingMaskIntoConstraints = false
        roommateCard.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        roommateCard.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        roommateCard.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        roommateCard.heightAnchor.constraint(equalToConstant: 166).isActive = true
        
        let matchesLabel = UILabel()
        matchesLabel.text = "Your Matches"
        matchesLabel.font = Font.bold(24)
        matchesLabel.adjustsFontSizeToFitWidth = true
        matchesLabel.textColor = Color.blackText
        roommateCard.addSubview(matchesLabel)
        matchesLabel.setContentHuggingPriority(.required, for: .vertical)
        matchesLabel.translatesAutoresizingMaskIntoConstraints = false
        matchesLabel.leftAnchor.constraint(equalTo: roommateCard.layoutMarginsGuide.leftAnchor).isActive = true
        matchesLabel.topAnchor.constraint(equalTo: roommateCard.layoutMarginsGuide.topAnchor).isActive = true
        if (SignInManager.shared.isSignedIn) {
            if RoommateFinder.shared.profile == nil {
                createProfileButtonView()
            } else {
                showMatches()
            }
        } else {
           signInButtonView()
        }
    }
    
    func setupActionButtons() {
        if SignInManager.shared.isSignedIn && RoommateFinder.shared.profile != nil {
            let editProfileButton = ActionButton(title: "Edit My Roommate Profile", defaultColor: Color.RoommateFinder.ActionButtons.action, pressedColor: Color.RoommateFinder.ActionButtons.actionPressed)
            editProfileButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
            self.view.addSubview(editProfileButton)
            editProfileButton.translatesAutoresizingMaskIntoConstraints = false
            editProfileButton.widthAnchor.constraint(equalTo: roommateCard.widthAnchor).isActive = true
            editProfileButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            editProfileButton.topAnchor.constraint(equalTo: roommateCard.bottomAnchor, constant: 20).isActive = true
            let deleteProfileButton = ActionButton(title: "Delete My Profile", defaultColor: Color.RoommateFinder.ActionButtons.disabled, pressedColor: Color.RoommateFinder.ActionButtons.disabledPressed)
            deleteProfileButton.addTarget(self, action: #selector(deleteProfile), for: .touchUpInside)
            self.view.addSubview(deleteProfileButton)
            deleteProfileButton.translatesAutoresizingMaskIntoConstraints = false
            deleteProfileButton.widthAnchor.constraint(equalTo: roommateCard.widthAnchor).isActive = true
            deleteProfileButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            deleteProfileButton.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: kViewMargin / 2).isActive = true
        }
    }
    
    func createProfileButtonView() {
        let createProfileButton = ActionButton(title: "Create Your Roommate Profile", defaultColor: Color.RoommateFinder.ActionButtons.action, pressedColor: Color.RoommateFinder.ActionButtons.actionPressed)
        createProfileButton.addTarget(self, action: #selector(createProfile), for: .touchUpInside)
        roommateCard.addSubview(createProfileButton)
        createProfileButton.translatesAutoresizingMaskIntoConstraints = false
        createProfileButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
        createProfileButton.centerYAnchor.constraint(equalTo: roommateCard.centerYAnchor, constant: 12).isActive = true
        createProfileButton.centerXAnchor.constraint(equalTo: roommateCard.centerXAnchor).isActive = true
    }
    
    func signInButtonView() {
        let signInButton = ActionButton(title: "Sign In to Find a Roommate", defaultColor: Color.RoommateFinder.ActionButtons.destructive, pressedColor: Color.RoommateFinder.ActionButtons.destructivePressed)
        signInButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        roommateCard.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
        signInButton.centerYAnchor.constraint(equalTo: roommateCard.centerYAnchor, constant: 12).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: roommateCard.centerXAnchor).isActive = true
    }
    
    func matchesPendingView() {
        let matchesPendingButton = ActionButton(title: "Matches Are Pending", defaultColor: Color.RoommateFinder.ActionButtons.disabled, pressedColor: Color.RoommateFinder.ActionButtons.disabledPressed)
        roommateCard.addSubview(matchesPendingButton)
        matchesPendingButton.translatesAutoresizingMaskIntoConstraints = false
        matchesPendingButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
        matchesPendingButton.centerYAnchor.constraint(equalTo: roommateCard.centerYAnchor, constant: 12).isActive = true
        matchesPendingButton.centerXAnchor.constraint(equalTo: roommateCard.centerXAnchor).isActive = true
    }
    
    func showMatches() {
        if RoommateFinder.shared.matches.isEmpty {
            matchesPendingView()
        } else {
            
        }
    }
    
    @objc func goToProfile() {
        if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
            tabBarController.selectProfileTab()
        }
    }
    
    /**
        Presents the create profile page for creating new profile.
     */
    @objc func createProfile() {
        
    }
    
    /**
        Presents the create profile page with pre-filled information.
     */
    @objc func editProfile() {
        
    }
    
    @objc func deleteProfile() {
        
    }
}

// MARK: - Analytics

extension RoommateViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("opened_roommate_screen", parameters: nil)
    }
}

extension RoommateViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // user signed in
    }
}

