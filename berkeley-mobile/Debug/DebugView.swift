//
//  DebugView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 12/15/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import FactoryKit
import SwiftUI

struct DebugView: View {
    @InjectedObservable(\.debugViewModel) private var debugViewModel

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                appInfoSection
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
    
    private var appInfoSection: some View {
        Section("App Information") {
            LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A")
            LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A")
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
        } footer: {
            if let feedbackFormConfig = debugViewModel.feedbackFormConfig {
                VStack(alignment: .leading) {
                    Text("Show feedback form every \(feedbackFormConfig.numToShow) launches.")
                    Text("Next launch in \(feedbackFormConfig.numToShow - debugViewModel.feedbackFormPresenter.currNumAppLaunchForFeedbackForm).")
                }
                .foregroundStyle(.secondary)
            } else {
                ProgressView()
                    .controlSize(.mini)
            }
        }
        .onAppear {
            debugViewModel.fetchFeedbackFormConfig()
        }
    }
}

#Preview {
    DebugView()
}
