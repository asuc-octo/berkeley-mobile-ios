//
//  StudyPact.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import GoogleSignIn

/// All StudyPact api call functions go in here. Relevant user info also goes here.
class StudyPact {
    static let shared = StudyPact()
    
    private var cryptoHash: String?
    var email: String?
    
    /// Load cryptohash from user defaults. If it doesnt exist or authenticate fails, return false.
    public func loadCryptoHash() -> Bool {
        if let cryptoHash = UserDefaults.standard.string(forKey: "userCryptoHash") {
            self.cryptoHash = cryptoHash
            authenticateUser { (success) in
                // TODO: Block thread? until done
            }
            return true
        }
        return false
    }
    
    /// Reset all properties. Should be called if user is signed out of google
    public func reset() {
        self.deleteCryptoHash()
        self.cryptoHash = nil
        self.email = nil
    }

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
              user.profile.email.hasSuffix("@berkeley.edu"),
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
    
    public func getUser(completion: @escaping (Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.getUser.url else {
            completion(false)
            return
        }
        let params = ["user_email": email, "secret_token": cryptohash]
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    // MARK: AddUser
    
    public func addUser(user: StudyGroupMember, completion: @escaping (Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let info = ["name": user.name, "phone": user.phoneNumber ?? "", "profile_picture": user.profilePictureURL ?? "", "facebook": user.facebookUsername ?? ""] as? [String: String],
              let url = EndpointKey.addUser.url else {
            completion(false)
            return
        }
        let params = ["user_email": user.email, "secret_token": cryptohash, "timezone": TimeZone.current.identifier, "info": info] as [String : Any]
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                completion(true)
            default:
                completion(false)
            }
        }
    }

    // MARK: AddClass

    public func addClass(preferences: StudyPactPreference, completion: @escaping(Bool) -> Void) {
        guard let cryptohash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.addClass.url,
              let params = AddClassParams(email: email, cryptohash: cryptohash, prefs: preferences)?.asJSON else {
            completion(false)
            return
        }
        NetworkManager.shared.post(url: url, body: params, asType: AnyJSON.self) { response in
            switch response {
            case .success(_):
                completion(true)
            default:
                completion(false)
            }
        }
    }

    // MARK: GetGroups
    
    public func getGroups(completion: @escaping ([StudyGroup]) -> Void) {
        guard let cryptoHash = self.cryptoHash,
              let email = self.email,
              let url = EndpointKey.getGroups.url else {
            completion([])
            return
        }
        let params = ["secret_token": cryptoHash, "user_email": email]
        NetworkManager.shared.post(url: url, body: params, asType: [StudyGroup].self) { response in
            switch response {
            case .success(let data):
                completion(data ?? [])
            default:
                completion([])
            }
        }
    }
    
    func getCryptoHash() -> String? {
        return cryptoHash
    }
    
    private func saveCryptoHash(cryptoHash: String) {
        UserDefaults.standard.set(cryptoHash, forKey: "userCryptoHash")
    }
    
    private func deleteCryptoHash() {
        UserDefaults.standard.removeObject(forKey: "userCryptoHash")
    }
}
