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
    let collaborative: Bool
    let virtual: Bool
    let pending: Bool
    let preferredNumberMembers: Int
}

struct StudyGroupMember {
    let profilePictureURL: URL?
    var profilePicture: UIImage?
    let name: String
    let email: String
    let phoneNumber: String?
}
