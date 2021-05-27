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
            print("signed in")
        } else {
            let signInButton = ActionButton(title: "Sign In to Find a Roommate", defaultColor: Color.RoommateFinder.ActionButtons.destructive, pressedColor: Color.RoommateFinder.ActionButtons.destructivePressed)
            signInButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
            roommateCard.addSubview(signInButton)
            signInButton.translatesAutoresizingMaskIntoConstraints = false
            signInButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
            signInButton.centerYAnchor.constraint(equalTo: roommateCard.centerYAnchor, constant: 12).isActive = true
            signInButton.centerXAnchor.constraint(equalTo: roommateCard.centerXAnchor).isActive = true
            
        }
        
        // TODO: add table of matches
    }
    
    @objc func goToProfile() {
        if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
            tabBarController.selectProfileTab()
        }
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

