//
//  SignInManager.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 2/3/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import GoogleSignIn

class SignInManager: NSObject, GIDSignInDelegate {
    static let shared = SignInManager()
    
    private var allDelegates: [GIDSignInDelegate] = []
    
    public var isSignedIn: Bool {
        get {
            return StudyPact.shared.getCryptoHash() != nil && self.user != nil
        }
    }
    
    public var user: GIDGoogleUser? {
        get {
            return GIDSignIn.sharedInstance()?.currentUser
        }
    }
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance()?.delegate = self
        if let previous = GIDSignIn.sharedInstance()?.hasPreviousSignIn(), previous {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            if !StudyPact.shared.loadCryptoHash() {
                GIDSignIn.sharedInstance()?.signOut()
                StudyPact.shared.reset()
            }
        } else {
            StudyPact.shared.reset()
        }
    }
    
    public func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        StudyPact.shared.email = user.profile.email
        for delegate in allDelegates {
            delegate.sign(signIn, didSignInFor: user, withError: error)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        for delegate in allDelegates {
            delegate.sign?(signIn, didDisconnectWith: user, withError: error)
        }
    }
    
    public func addDelegate(delegate: GIDSignInDelegate) {
        allDelegates.append(delegate)
    }
}
