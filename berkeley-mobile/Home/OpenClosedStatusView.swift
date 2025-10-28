//
//  OpenClosedStatusView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/17/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct OpenClosedStatusView: View {
    enum Status: String {
        case open = "Open"
        case closed = "Closed"
        
        var color: Color {
            switch self {
            case .open:
                return .green
            case .closed:
                return .red
            }
        }
    }
    
    var status: OpenClosedStatusView.Status
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            Text(status.rawValue)
                .font(Font(BMFont.light(12)))
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Group {
        OpenClosedStatusView(status: .open)
        OpenClosedStatusView(status: .closed)
    }
}
