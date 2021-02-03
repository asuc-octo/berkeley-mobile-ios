//
//  StudyGroup.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/21/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

struct StudyGroup {
    let className: String
    let groupMembers: [StudyGroupMember]
    let pending: Bool
}

struct StudyGroupMember {
    let profilePictureURL: URL?
    let name: String
    let email: String
    let phoneNumber: String?
    let facebookUsername: String?
}
