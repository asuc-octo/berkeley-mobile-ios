//
//  AuthenticateUser.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/3/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

struct AuthenticateUserParams: Encodable {
    let email: String
    let cryptohash: String

    enum CodingKeys: String, CodingKey {
        case email = "Email", cryptohash = "CryptoHash"
    }
}

struct AuthenticateUserDocument: Decodable {
    let valid: Bool
    let _info: AnyJSON

    var info: JSONObject? { _info.unwrapped as? JSONObject }

    enum CodingKeys: String, CodingKey {
        case valid = "isValid", _info = "UserInfo"
    }
}
