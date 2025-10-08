//
//  EnvironmentValues+Ext.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/7/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import SwiftUI

private struct MenuIconCacheKey: EnvironmentKey {
    static var defaultValue: MenuItemIconCaching = MenuItemIconCacheManager()
}

extension EnvironmentValues {
    var menuIconCache: MenuItemIconCaching {
        get { self[MenuIconCacheKey.self] }
        set { self[MenuIconCacheKey.self] = newValue }
    }
}
