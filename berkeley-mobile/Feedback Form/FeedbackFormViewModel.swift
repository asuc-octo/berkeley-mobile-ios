//
//  FeedbackFormViewModel.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/14/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Firebase
import Foundation
import Observation
import os

fileprivate let kFeedbackFormConfigEndpoint = "Feedback Form Config"
fileprivate let kFeedbackFormConfigDocName = "config-data"
fileprivate let kFeedbackResponsesCollection = "Feedback Responses"

struct FeedbackFormConfig: Codable {
    var instructionText: String
    var sectionsAndQuestions: [FeedbackFormSectionQuestions]
    var numToShow: Int
    
}

struct FeedbackFormSectionQuestions: Codable {
    var questionTitle: String
    var questions: [String]
}

@Observable
class FeedbackFormViewModel {
    var config: FeedbackFormConfig?
    var isSubmitting = false
    
    private let db = Firestore.firestore()
    
    func fetchFeedbackFormConfig() async -> FeedbackFormConfig? {
        let docRef = db.collection(kFeedbackFormConfigEndpoint).document(kFeedbackFormConfigDocName)
        
        do {
            let formConfig = try await docRef.getDocument(as: FeedbackFormConfig.self)
            return formConfig
        } catch {
            Logger.feedbackFormConfig.error("Failed to fetch feedback form config: \(error.localizedDescription)")
        }
        return nil
    }
    @MainActor
    func submitFeedbackFromForm(
        email: String,
        checkboxAnswers: [String: Bool],
        textAnswers: [String: String],
        config: FeedbackFormConfig,
        isEmailValid: Bool,
        onDismiss: @escaping () -> Void
    ) async {
        guard isEmailValid else { return }
        
        isSubmitting = true
        
        var responses: [[String: Any]] = []
        
        for section in config.sectionsAndQuestions {
            var sectionData: [String: Any] = [
                "questionTitle": section.questionTitle,
                "answers": [String]()
            ]
            if section.questions.contains("") {
                if let textResponse = textAnswers[section.questionTitle], !textResponse.isEmpty {
                    sectionData["answers"] = [textResponse]
                }
            } else {
                let selectedAnswers = section.questions.filter {
                    checkboxAnswers[$0, default: false]
                }
                sectionData["answers"] = selectedAnswers
            }
            responses.append(sectionData)
        }
        let feedbackData: [String: Any] = [
            "email": email.lowercased(),
            "submittedAt": FieldValue.serverTimestamp(),
            "responses": responses
        ]
        do {
            try await db.collection(kFeedbackResponsesCollection)
                .document(email.lowercased())
                .setData(feedbackData)
            Logger.feedbackFormConfig.info("Successfully submitted feedback for \(email)")
        } catch {
            Logger.feedbackFormConfig.error("Failed to submit for \(email): \(error.localizedDescription)")
        }
        
        isSubmitting = false
        onDismiss()
    }
}
