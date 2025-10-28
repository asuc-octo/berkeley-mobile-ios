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
    
    // NEW: Add ViewModel and simplified state
    @State private var viewModel = FeedbackFormViewModel()
    @State private var checkboxAnswers: [String: Bool] = [:]
    @State private var textAnswers: [String: String] = [:]
    @State private var email = ""
    @State private var isSubmitting = false
    
    // KEEP: This stays the same
    var config: FeedbackFormConfig
    
    // KEEP: This stays the same
    private var isEmailValid: Bool {
        return !email.isEmpty && email.contains("@berkeley.edu")
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Instruction text
                Section {
                    Text(config.instructionText)
                        .foregroundColor(.secondary)
                }
                
                // Email section
                emailSection
                
                // Dynamic sections from config
                ForEach(config.sectionsAndQuestions, id: \.questionTitle) { section in
                    Section(header: Text(section.questionTitle)) {
                        if section.questions.contains("") {
                            // Empty string means open-ended text field
                            TextEditor(text: Binding(
                                get: { textAnswers[section.questionTitle, default: ""] },
                                set: { textAnswers[section.questionTitle] = $0 }
                            ))
                            .frame(minHeight: 100)
                        } else {
                            // Checkbox options
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
                
                // Submit button
                submitButtonSection
            }
            .navigationBarTitle("We Want Your Feedback!", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: dismissForm) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .disabled(isSubmitting)
        }
    }
    
    // NEW: Updated email section
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
    
    // NEW: Updated submit button with loading state
    private var submitButtonSection: some View {
        Section {
            Button(action: submitFeedbackForm) {
                HStack {
                    Spacer()
                    if isSubmitting {
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
            .disabled(!isEmailValid || isSubmitting)
        }
        .listRowBackground(Color.clear)
    }
    
    // NEW: Simplified submit function using ViewModel
    private func submitFeedbackForm() {
        guard isEmailValid else { return }
        
        isSubmitting = true
        
        Task {
            await viewModel.submitFeedback(
                email: email.lowercased(),
                checkboxAnswers: checkboxAnswers,
                textAnswers: textAnswers,
                config: config
            )
            
            dismissForm()
        }
    }
    
    // KEEP: This stays the same
    private func dismissForm() {
        dismiss()
        UserDefaults.standard.set(2, forKey: .numAppLaunchForFeedbackForm)
    }
}

struct FeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
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
        FeedbackFormView(config: formConfig)
    }
}

