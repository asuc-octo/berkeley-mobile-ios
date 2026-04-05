//
//  TimeInterval+Ext.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/29/26.
//  Copyright © 2026 ASUC OCTO. All rights reserved.
//

import Foundation

extension TimeInterval {
    init(minutes: Double) {
        self = minutes * 60
    }
}
