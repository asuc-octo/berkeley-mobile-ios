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
    private var email: String?
    
    init() {
        guard let cryptoHash = UserDefaults.standard.string(forKey: "userCryptoHash") else { return }
        // TODO: call AuthenticateUser. if authenticate fails but signed into google, call RegisterUser
    }

    public func getBerkeleyCourses(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "https://berkeleytime.com/api/catalog/catalog_json/") else {
            completion([])
            return
        }
        NetworkManager.shared.get(url: url, params: [:], asType: CoursesDocument.self) { response in
            switch response {
            case .success(let document):
                guard let document = document else { break }
                completion(document.courses.map { $0.abbreviation + " " + $0.number })
            default:
                break
            }
            completion([])
        }
    }
    
    public func registerUser(user: GIDGoogleUser?, completion: @escaping (Bool) -> Void) {
        guard let user = user,
              user.profile.email.hasSuffix("@berkeley.edu"),
              let params = ["Email": user.profile.email, "FirstName": user.profile.givenName, "LastName": user.profile.familyName] as? [String: String],
              let urlString = API_URLS[EndpointKey.registerUser.rawValue],
              let url = URL(string: urlString) else {
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
                break
            }
            completion(false)
        }
    }
    
    public func getGroups(completion: @escaping ([StudyGroup]) -> Void) {
        guard let cryptoHash = self.cryptoHash,
              let email = self.email,
              let urlString = API_URLS[EndpointKey.getGroups.rawValue],
              let url = URL(string: urlString) else {
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
}
