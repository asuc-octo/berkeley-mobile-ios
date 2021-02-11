//
//  StudyPact.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import GoogleSignIn

fileprivate let kCryptoHashKey = "userCryptoHash"

/// All StudyPact API call functions go in here. Relevant user info also goes here.
class StudyPact {

    static let shared = StudyPact()
    
    private var cryptoHash: String?
    var email: String?
    var groupUpdateDelegates: [GroupUpdateDelegate] = []

    /// Load cryptohash from user defaults. If it doesnt exist or authenticate fails, return false.
    public func loadCryptoHash(completion: @escaping (Bool) -> Void) {
        if let cryptoHash = UserDefaults.standard.string(forKey: kCryptoHashKey) {
            self.cryptoHash = cryptoHash
            authenticateUser(completion: completion)
        } else {
            completion(false)
        }
    }
    
    /// Reset all properties. Should be called if user is signed out of google
    public func reset() {
        self.deleteCryptoHash()
        self.cryptoHash = nil
        self.email = nil
    }

    func getCryptoHash() -> String? {
        return cryptoHash
    }

    private func saveCryptoHash(cryptoHash: String) {
        UserDefaults.standard.set(cryptoHash, forKey: kCryptoHashKey)
    }

    private func deleteCryptoHash() {
        UserDefaults.standard.removeObject(forKey: kCryptoHashKey)
    }
}

// MARK: - API

extension StudyPact {

    // MARK: GetBerkeleyCourses

    public func getBerkeleyCourses(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "https://berkeleytime.com/api/catalog/catalog_json/") else {
            completion([])
            return
        }
        NetworkManager.shared.get(url: url, params: [String: String](), asType: CoursesDocument.self) { response in
            switch response {
            case .success(let document):
                guard let document = document else { break }
                completion(document.courses.map { $0.abbreviation + " " + $0.number })
            default:
                completion([])
            }
        }
    }

    // MARK: RegisterUser
    
    public func registerUser(user: GIDGoogleUser?, completion: @escaping (Bool) -> Void) {
        guard let user = user,
              (user.profile.email.hasSuffix("@berkeley.edu") || user.profile.email == DEMO_EMAIL),
              let params = ["Email": user.profile.email, "FirstName": user.profile.givenName, "LastName": user.profile.familyName] as? [String: String],
              let url = EndpointKey.registerUser.url else {
            completion(false)
            return
        }
        NetworkManager.shared.post(url: url, body: params) { response in
            switch response {
            case .success(let data):
                guard let data = data, let cryptohash = data["CryptoHash"] as? String else { break }
                self.cryptoHash = cryptohash
                self.email = user.profile.email
                self.saveCryptoHash(cryptoHash: cryptohash)
                completion(true)
            default:
                completion(false)
            }
        }
    }

    // MARK: AuthenticateUser

    public func authenticateUser(completion: @escaping (Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.authenticateUser.url else {
            completion(false)
            return
        }
        let params = ["Email": email, "CryptoHash": cryptohash]
        NetworkManager.shared.post(url: url, body: params, asType: AuthenticateUserDocument.self) { response in
            switch response {
            case .success(let data):
                completion(data?.valid ?? false)
            default:
                completion(false)
            }
        }
    }

    // MARK: GetUser

    // MARK: AddUser

    // MARK: AddClass

    public func addClass(preferences: StudyPactPreference, completion: @escaping(Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.addClass.url,
              let params = AddPreferenceParams(email: email, cryptohash: cryptohash, prefs: preferences)?.asJSON else {
            completion(false)
            return
        }
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                for delegate in self.groupUpdateDelegates {
                    delegate.refreshGroups()
                }
                completion(true)
            default:
                completion(false)
            }
        }
    }

    // MARK: CancelPending

    public func cancelPending(group: StudyGroup, completion: @escaping(Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.cancelPending.url,
              let params = RemovePreferenceParams(email: email, cryptohash: cryptohash, id: group.id).asJSON else {
            completion(false)
            return
        }
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                for delegate in self.groupUpdateDelegates {
                    delegate.refreshGroups()
                }
                completion(true)
            default:
                completion(false)
            }
        }
    }

    // MARK: LeaveGroup

    // MARK: GetGroups
    
    public func getGroups(completion: @escaping ([StudyGroup]) -> Void) {
        guard let cryptoHash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.getGroups.url else {
            completion([])
            return
        }
        let params = ["secret_token": cryptoHash, "user_email": email]
        NetworkManager.shared.get(url: url, params: params, asType: [StudyGroup].self) { response in
            switch response {
            case .success(let data):
                completion(data ?? [])
            default:
                completion([])
            }
        }
    }
    
    /// MARK: LeaveGroup
    // backend hasn't implemented this yet, may need to modify
    public func leaveGroup(group: StudyGroup, completion: @escaping (Bool) -> Void) {
        guard let cryptoHash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.leaveGroup.url else {
            completion(false)
            return
        }
        let params = ["secret_token": cryptoHash, "user_email": email, "group_id": group.id]
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                for delegate in self.groupUpdateDelegates {
                    delegate.refreshGroups()
                }
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

protocol GroupUpdateDelegate {
    func refreshGroups() -> Void
}
