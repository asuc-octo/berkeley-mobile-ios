//
//  DebugView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct DebugView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let debugViewModel: DebugViewModel
    
    init(debugViewModel: DebugViewModel) {
        self.debugViewModel = debugViewModel
    }
    
    var body: some View {
        NavigationStack {
            List {
                presentFeedbackFormSection
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private var presentFeedbackFormSection: some View {
        Section {
            Button(action: {
                dismiss()
                debugViewModel.presentFeedbackForm()
            }) {
                Label("Present Feedback Form", systemImage: "questionmark.bubble")
            }
        }
    }
}

#Preview {
    let feedbackFormPresenter = FeedbackFormPresenter()
    let debugViewModel = DebugViewModel(feedbackFormPresenter: feedbackFormPresenter)
    DebugView(debugViewModel: debugViewModel)
}
