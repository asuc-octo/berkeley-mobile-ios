//
//  StudyPact+Endpoints.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/2/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

extension StudyPact {
    enum EndpointKey: String {
        case registerUser = "REGISTER_USER"
        case authenticateUser = "AUTHENTICATE_USER"
        case getUser = "GET_USER"
        case addUser = "ADD_USER"
        case addClass = "ADD_CLASS"
        case cancelPending = "CANCEL_PENDING"
        case leaveGroup = "LEAVE_GROUP"
        case getGroups = "GET_GROUPS"
    }
}
