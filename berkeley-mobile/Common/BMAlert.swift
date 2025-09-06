//
//  BMAlert.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/4/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation


struct BMAlert: Equatable, Identifiable {
    enum BMAlertType {
        case action
        case notice
    }
    
    let id = UUID()
    var title: String
    var message: String
    var type: BMAlertType
    var completion: (() -> Void)?
    
    static func == (lhs: BMAlert, rhs: BMAlert) -> Bool {
        lhs.id == rhs.id
    }
}
