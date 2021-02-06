//
//  StudyGroup.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

struct StudyGroup: Decodable {
    let className: String
    let groupMembers: [StudyGroupMember]
    let size: Int
    let pending: Bool
    let id: String

    enum CodingKeys: String, CodingKey {
        case className = "class_name", groupMembers = "users", pending, id, size
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
