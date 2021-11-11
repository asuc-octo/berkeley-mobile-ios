//
//  Display.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 3/13/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation

/// Wrapper for strings intended to be displayed. Removes excess whitespace and invalid characters.
/// Type `T` must be `String` or `String?`.
@propertyWrapper struct Display<T> {

    private var _display: T

    var wrappedValue: T {
        get { return _display }
        set { _display = Display.wrap(newValue) }
    }

    init(wrappedValue: T) where T == String { _display = Display.wrap(wrappedValue) }
    init(wrappedValue: T) where T == String? { _display = Display.wrap(wrappedValue) }

    private static func wrap(_ rawString: String) -> String {
        return rawString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: Strings.invalidCharacter, with: "")
    }

    private static func wrap(_ rawValue: String?) -> String? {
        guard let rawString = rawValue else { return rawValue }
        return Display.wrap(rawString)
    }

    private static func wrap(_ rawValue: T) -> T {
        guard let rawString = rawValue as? String else { return rawValue }
        guard let wrappedValue = Display.wrap(rawString) as? T else { return rawValue }
        return wrappedValue
    }
}
