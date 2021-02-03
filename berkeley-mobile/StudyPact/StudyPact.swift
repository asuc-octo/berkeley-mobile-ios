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
    var studyGroups: [StudyGroup] = []
    
    init() {
        if let cryptoHash = UserDefaults.standard.string(forKey: "userCryptoHash") {
            // TODO: authenticate user first. if authenticate fails sign out of google and reset stored cryptohash and relevant variables
            if let previous = GIDSignIn.sharedInstance()?.hasPreviousSignIn(), previous {
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                self.cryptoHash = cryptoHash
                self.email = GIDSignIn.sharedInstance()?.currentUser.profile.email
            } else {
                self.deleteCryptoHash()
                self.cryptoHash = nil
                self.email = nil
                self.studyGroups = []
            }
        }
        
    }
    
    public func getBerkeleyCourses(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "https://berkeleytime.com/api/catalog/catalog_json/") else {
            completion([])
            return
        }
        getRequest(url: url) { data in
            guard let data = data,
                  let json = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, AnyObject>,
                  let courses = json["courses"] as? Array<Dictionary<String, AnyObject>> else {
                completion([])
                return
            }
            var classNames: [String] = []
            for course in courses {
                guard let courseNumber = course["course_number"] as? String,
                      let abbreviation = course["abbreviation"] as? String else { continue }
                classNames.append(abbreviation + " " + courseNumber)
            }
            completion(classNames)
        }
    }
    
    public func registerUser(user: GIDGoogleUser?, completion: @escaping (Bool) -> Void) {
        guard let user = user,
              user.profile.email.hasSuffix("@berkeley.edu"),
              let params = ["Email": user.profile.email, "FirstName": user.profile.givenName, "LastName": user.profile.familyName] as? Dictionary<String, String>,
              let urlString = API_URLS["REGISTER_USER"],
              let url = URL(string: urlString) else {
            completion(false)
            return
        }
        postRequest(url: url, params: params) { data in
            guard let data = data,
                  let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>,
                  let cryptoHash = json["CryptoHash"] as? String else {
                completion(false)
                return
            }
            self.cryptoHash = cryptoHash
            self.email = user.profile.email
            self.saveCryptoHash(cryptoHash: cryptoHash)
            completion(true)
        }
    }
    
    public func getGroups(completion: @escaping ([StudyGroup]) -> Void) {
        guard let cryptoHash = self.cryptoHash,
              let email = self.email,
              let urlString = API_URLS["GET_GROUPS"],
              let url = URL(string: urlString) else {
            completion([])
            return
        }
        let params = ["secret_token": cryptoHash, "user_email": email]
        postRequest(url: url, params: params) { data in
            guard let data = data,
                  let json = try JSONSerialization.jsonObject(with: data, options: []) as? Array<Dictionary<String, AnyObject>> else {
                completion([])
                return
            }
            var groups: [StudyGroup] = []
            for group in json {
                guard let className = group["class_name"] as? String,
                      let users = group["users"] as? Array<AnyObject>,
                      let pending = group["pending"] as? Bool else {
                    continue
                }
                var studyGroupMembers: [StudyGroupMember] = []
                for user in users {
                    guard let userDict = user as? Dictionary<String, String>,
                          let name = userDict["name"],
                          let email = userDict["email"] else {
                        continue
                    }
                    let profileUrlString = userDict["profile_picture"]
                    let member = StudyGroupMember(profilePictureURL: URL(string: profileUrlString ?? ""),
                                                  name: name, email: email,
                                                  phoneNumber: userDict["phone"],
                                                  facebookUsername: userDict["facebook"])
                    studyGroupMembers.append(member)
                }
                let group = StudyGroup(className: className, groupMembers: studyGroupMembers, pending: pending)
                groups.append(group)
            }
            self.studyGroups = groups
            completion(groups)
        }
    }
    
    private func postRequest(url: URL, params: Dictionary<String, String>, completion: @escaping (Data?) throws -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data, let response = response,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  error == nil else {
                do {
                    try completion(nil)
                } catch {}
                return
            }
            do {
                try completion(data)
            } catch {}
            return
        })
        task.resume()
    }
    
    private func getRequest(url: URL, completion: @escaping (Data?) throws -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data, let response = response,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  error == nil else {
                do {
                    try completion(nil)
                } catch {}
                return
            }
            do {
                try completion(data)
            } catch {}
            return
        })
        task.resume()
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
