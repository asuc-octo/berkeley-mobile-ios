//
//  BMAlertView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 5/8/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

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

struct BMAlertView: View {
    @Environment(\.dismiss) private var dismiss
    
    var alert: BMAlert
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            VStack {
                Spacer()
                alertContentView
                Spacer()
            }
        }
    }
    
    private var alertContentView: some View {
        VStack(spacing: 15) {
            if !alert.title.isEmpty {
                Text(alert.title)
                    .font(Font(BMFont.bold(18)))
            }
           
            if !alert.message.isEmpty {
                Text(alert.message)
                    .multilineTextAlignment(.center)
                    .font(Font(BMFont.regular(15)))
            }
            
            HStack {
                if alert.type == .action {
                    BMActionButton(title: "Cancel", backgroundColor: Color(BMColor.AlertView.secondaryButton), showShadow: false) {
                        dismissWithoutAnimation()
                    }
                    .frame(width: 100)
                    
                    BMActionButton(title: "Yes", backgroundColor: Color(BMColor.ActionButton.background), showShadow: false) {
                        performAlertAction()
                    }
                    .frame(width: 100)
                } else {
                    BMActionButton(title: "OK", backgroundColor: Color(BMColor.ActionButton.background), showShadow: false) {
                        performAlertAction()
                    }
                    .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color(BMColor.modalBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 350)
    }
    
    private func performAlertAction() {
        switch alert.type {
        case .action:
            alert.completion?()
        case .notice:
            dismissWithoutAnimation()
        }
    }
    
    private func dismissWithoutAnimation() {
        withoutAnimation {
            dismiss()
        }
    }
}

#Preview {
    BMAlertView(alert: BMAlert(title: "Add To Calendar", message: "Would you like to add this event to your calendar?", type: .action))
}
