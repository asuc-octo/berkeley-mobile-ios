//
//  StudyGroup.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

struct StudyGroup: Decodable {
    let id: String?
    let className: String
    let allGroupMembers: [StudyGroupMember]
    let size: Int
    let pending: Bool

    enum CodingKeys: String, CodingKey {
        case className = "class_name", allGroupMembers = "users", pending, id, size
    }
}
extension StudyGroup {
    var groupMembers: [StudyGroupMember] {
        get {
            var members = allGroupMembers
            members.removeAll { member in
                member.email == StudyPact.shared.email
            }
            return members
        }
    }
}

struct StudyGroupMember: Decodable {
    let profilePictureURL: URL?
    let name: String
    let email: String
    let phoneNumber: String?
    let facebookUsername: String?

    enum CodingKeys: String, CodingKey {
        case profilePictureURL = "profile_picture", name, email,
             phoneNumber = "phone", facebookUsername = "facebook"
    }
}
