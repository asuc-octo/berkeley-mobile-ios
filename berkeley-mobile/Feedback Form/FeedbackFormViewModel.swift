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

fileprivate let kFeedbackFormConfigEndpoint = "Feedback Form Config"
fileprivate let kFeedbackFormConfigDocName = "config-data"
fileprivate let kFeedbackResponsesCollection = "Feedback Responses"

struct FeedbackFormConfig: Codable {
    var instructionText: String
    var sectionsAndQuestions: [FeedbackFormSectionQuestions]
    var numToShow: Int
    
    enum CodingKeys: String, CodingKey {
        case instructionText
        case sectionsAndQuestions
        case numToShow
    }
}

struct FeedbackFormSectionQuestions: Codable {
    var questionTitle: String
    var questions: [String]
}

@Observable
class FeedbackFormViewModel {
    var config: FeedbackFormConfig?
    
    private let db = Firestore.firestore()
    
    func fetchFeedbackFormConfig() async -> FeedbackFormConfig? {
        let docRef = db.collection(kFeedbackFormConfigEndpoint).document(kFeedbackFormConfigDocName)
        
        do {
            let formConfig = try await docRef.getDocument(as: FeedbackFormConfig.self)
            print("Successfully fetched form config")
            return formConfig
        } catch {
            print("Error fetching form config: \(error)")
        }
        
        return nil
    }
    
    func submitFeedback(
        email: String,
        checkboxAnswers: [String: Bool],
        textAnswers: [String: String],
        config: FeedbackFormConfig
    ) async {
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
            "email": email,
            "submittedAt": FieldValue.serverTimestamp(),
            "responses": responses
        ]
        
        do {
            try await db.collection(kFeedbackResponsesCollection)
                .document(email)
                .setData(feedbackData)
            
            print("Feedback submitted successfully for \(email)")
        } catch {
            print("Error submitting feedback: \(error)")
        }
    }
    
}
