//
//  Encodable+JSON.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/3/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

extension Encodable {
    var asJSON: JSONObject? {
        let encoder = JSONEncoder()
        do { return try JSONSerialization.jsonObject(with: encoder.encode(self)) as? JSONObject }
        catch { return nil }
    }
}
