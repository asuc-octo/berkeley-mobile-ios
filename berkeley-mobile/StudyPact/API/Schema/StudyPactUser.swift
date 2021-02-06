//
//  StudyPactUser.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/6/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

struct StudyPactUserDocument: Decodable {
    let email: String
    let _info: AnyJSON

    var info: JSONObject? { _info.unwrapped as? JSONObject }

    enum CodingKeys: String, CodingKey {
        case email = "user_email", _info = "UserInfo"
    }
}
