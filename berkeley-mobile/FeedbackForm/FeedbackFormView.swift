//
//  FeedbackFormView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 9/14/23.
//  Copyright © 2023 ASUC OCTO. All rights reserved.
//

import Firebase
import SwiftUI

struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var checkboxAnswers: [String: Bool] = [:]
    @State private var textAnswers: [String: String] = [:]
    @State private var email = ""
    
    private var viewModel: FeedbackFormViewModel
    private var config: FeedbackFormConfig
    
    private var isEmailValid: Bool {
        return !email.isEmpty && email.contains("@berkeley.edu")
    }
    
    init(viewModel: FeedbackFormViewModel, config: FeedbackFormConfig) {
        self.viewModel = viewModel
        self.config = config
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(config.instructionText)
                        .foregroundColor(.secondary)
                }
                
                emailSection
                ForEach(config.sectionsAndQuestions, id: \.questionTitle) { section in
                    Section(header: Text(section.questionTitle)) {
                        if section.questions.contains("") {
                            TextEditor(text: Binding(
                                get: { textAnswers[section.questionTitle, default: ""] },
                                set: { textAnswers[section.questionTitle] = $0 }
                            ))
                            .frame(minHeight: 100)
                        } else {
                            ForEach(section.questions, id: \.self) { question in
                                HStack {
                                    Text(question)
                                    Spacer()
                                    Button(action: {
                                        checkboxAnswers[question, default: false].toggle()
                                    }) {
                                        Image(systemName: checkboxAnswers[question, default: false] ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 25))
                                            .foregroundColor(checkboxAnswers[question, default: false] ? .blue : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
                
                submitButtonSection
            }
            .navigationBarTitle("We Want Your Feedback!", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26.0, *) {
                        Button(role: .cancel) {
                            dismissForm()
                        }
                    } else {
                        Button(action: dismissForm) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .disabled(viewModel.isSubmitting)
        }
    }
    
    private var emailSection: some View {
        Section(
            header: Text("Berkeley Email \(!isEmailValid ? "(Required)" : "")")
                .foregroundColor(!isEmailValid ? .red : Color.gray)
        ) {
            TextField("your.email@berkeley.edu", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(!isEmailValid && !email.isEmpty ? Color.red : Color.blue, lineWidth: 1)
                )
        }
    }
    
    private var submitButtonSection: some View {
        Section {
            Button(action: {
                Task {
                    await viewModel.submitFeedbackForm(
                        email: email.lowercased(),
                        checkboxAnswers: checkboxAnswers,
                        textAnswers: textAnswers,
                        onDismiss: dismissForm
                    )
                }
            }) {
                HStack {
                    Spacer()
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Submit")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 25))
                    }
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(DepthButtonStyle(color: isEmailValid ? Color.green : Color.gray))
        }
        .listRowBackground(Color.clear)
    }
    
    private func dismissForm() {
        dismiss()
        UserDefaults.standard.set(0, forKey: .numAppLaunchForFeedbackForm)
    }
}

#Preview {
    let viewModel = FeedbackFormViewModel()
    let formConfig = FeedbackFormConfig(
        instructionText: "Please share your thoughts about the Berkeley Mobile app!",
        sectionsAndQuestions: [
            FeedbackFormSectionQuestions(
                questionTitle: "What features do you like?",
                questions: ["Maps", "Dining", "Library"]
            ),
            FeedbackFormSectionQuestions(
                questionTitle: "Additional comments",
                questions: [""]
            )
        ],
        numToShow: 20
    )
    FeedbackFormView(viewModel: viewModel, config: formConfig)
}
