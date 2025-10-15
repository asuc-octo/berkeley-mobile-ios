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


struct FeedbackFormConfig: Codable {
    var instructionText: String
    var sectionsAndQuestions: [FeedbackFormSectionQuestions]
    var numOfAppLaunchesToShow: Int
    
    enum CodingKeys: String, CodingKey {
        case instructionText
        case sectionsAndQuestions
        case numOfAppLaunchesToShow = "numToShow"
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
            print(formConfig)
            return formConfig
        } catch {
           print("Error fetching form config: \(error)")
        }
        
        return nil
    }
}
