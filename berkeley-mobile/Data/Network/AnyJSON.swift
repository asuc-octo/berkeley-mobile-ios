//
//  AnyJSON.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 2/3/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

enum JSONType: CaseIterable {
    case null
    case int
    case double
    case string
    case bool
    case array
    case dictionary
}

struct AnyJSON: Decodable {

    private let value: Any?
    private let type: JSONType

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        var object: Any?
        var type: JSONType = .null
        for _type in JSONType.allCases {
            type = _type
            switch type {
            case .int:
                object = try? container.decode(Int.self)
            case .double:
                object = try? container.decode(Double.self)
            case .string:
                object = try? container.decode(String.self)
            case .bool:
                object = try? container.decode(Bool.self)
            case .array:
                object = try? container.decode([AnyJSON].self)
            case .dictionary:
                object = try? container.decode([String: AnyJSON].self)
            default:
                break
            }

            if object != nil { break }
        }

        self.value = object
        self.type = object == nil ? .null : type
    }

    public var unwrapped: Any? {
        guard let value = value else { return nil }
        switch type {
        case .dictionary:
            guard let dict = value as? [String: AnyJSON] else { return nil }
            return dict.mapValues { $0.unwrapped }
        case .array:
            guard let arr = value as? [AnyJSON] else { return nil }
            return arr.map { $0.unwrapped }
        default:
            return value
        }
    }
}
