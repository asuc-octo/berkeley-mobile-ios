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
    
    @State private var email = ""
    @State private var selectedMostLikedFeatures = [String]()
    @State private var selectedWantedFeatures = [String]()
    @State private var selectedPetPeeves = [String]()
    @State private var otherMostLikedFeatures = ""
    @State private var otherWantedFeatures = ""
    @State private var otherPetPeeves = ""
    @State private var otherComments = ""
    
    private let mostLikedFeaturesOptions = [
        "Directory Of Library Study Spots",
        "Home Page Resources On Map",
        "Study/Dining/Fitness Information"
    ]
    private let wantedFeaturesOptions = [
        "School Events & Clubs Page",
        "Safety: Warn Me & UCPD Alerts",
        "Digital Cal-ID",
        "Digital Flyers"
    ]
    private let petPeevesOptions = [
        "School-Wide Safety",
        "Difficult Socializing Environment"
    ]
    
    private var isEmailValid: Bool {
        return !email.isEmpty && email.contains("@berkeley.edu")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Text("Please take 1-2 minutes to fill out this survey! We really appreciate the feedback! 🙏")
                    .foregroundColor(.secondary)
                emailSection
                likeFeaturesSection
                wantFeaturesSection
                petPeevesSection
                otherCommentsSection
                submitButtonSection
            }
            .navigationBarTitle("We Want Your Feedback!", displayMode: .inline)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            dismissForm()
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            dismissForm()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
    }
    
    private var emailSection: some View {
        Section(header: Text("Berkeley Email \(!isEmailValid ? "(Required)" : "") ")
            .foregroundColor(!isEmailValid ? .red : Color.gray)
        ) {
            TextField("", text: $email)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(!isEmailValid ? Color.red : Color.blue, lineWidth: 1)
                    
                )
                .background(!isEmailValid ? Color.red.opacity(0.1) : Color.clear)
        }
    }
    
    private var likeFeaturesSection: some View {
        Section(header: Text("What features on the app do you like the most?")) {
            ForEach(Array(mostLikedFeaturesOptions.enumerated()), id: \.element) { index, option in
                FeedbackFormOptionRow(options: mostLikedFeaturesOptions, selectedOptions: $selectedMostLikedFeatures, optionTitle: option)
            }
            HStack {
                TextField("Other", text: $otherMostLikedFeatures)
            }
        }
    }
    
    private var wantFeaturesSection: some View {
        Section(header: Text("What features do you want on the app?")) {
            ForEach(Array(wantedFeaturesOptions.enumerated()), id: \.element) { index, option in
                FeedbackFormOptionRow(options: wantedFeaturesOptions, selectedOptions: $selectedWantedFeatures, optionTitle: option)
            }
            HStack {
                TextField("Other", text: $otherWantedFeatures)
            }
        }
    }
    
    private var petPeevesSection: some View {
        Section(header: Text("What are you biggest pet peeves with campus?")) {
            ForEach(Array(petPeevesOptions.enumerated()), id: \.element) { index, option in
                FeedbackFormOptionRow(options: petPeevesOptions, selectedOptions: $selectedPetPeeves, optionTitle: option)
            }
            HStack {
                TextField("Other", text: $otherPetPeeves)
            }
        }
    }
    
    private var otherCommentsSection: some View {
        Section(header: Text("Any other comments and concerns about the app?")) {
            TextEditor(text: $otherComments)
        }
    }
    
    private var submitButtonSection: some View {
        Section {
            Button(action: {
                submitFeedbackForm()
            }) {
                HStack {
                    Spacer()
                    Text("Submit")
                        .foregroundColor(.white).bold()
                        .font(.system(size: 25))
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(DepthButtonStyle(color: Color.green))
        }
        .listRowBackground(Color.clear)
    }
    
    private func submitFeedbackForm() {
        let email = email.lowercased()
        guard isEmailValid else { return }
        
        let db = Firestore.firestore()
        db.collection("Feedback Forms").document(email).setData([
            "email": email,
            "selectedMostLikedFeatures": selectedMostLikedFeatures,
            "selectedWantedFeatures": selectedWantedFeatures,
            "selectedPetPeeves": selectedPetPeeves,
            "otherMostLikedFeatures":
                otherMostLikedFeatures,
            "otherWantedFeatures":
                otherWantedFeatures,
            "otherPetPeeves":
                otherPetPeeves,
            "otherComments":
                otherComments
        ])
        
        dismissForm()
    }
    
    private func dismissForm() {
        dismiss()
        UserDefaults.standard.set(2, forKey: .numAppLaunchForFeedbackForm)
    }
}

struct FeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackFormView()
    }
}


//MARK: - FeedbackFormOptionRow

struct FeedbackFormOptionRow: View {
    var options: [String]
    @Binding var selectedOptions: [String]
    var optionTitle: String
    
    @State private var isChecked: Bool = false
    
    var body: some View {
        HStack {
            Text(optionTitle)
            Spacer()
            Button(action: {
                if isChecked {
                    if let index = selectedOptions.firstIndex(of: optionTitle) {
                        selectedOptions.remove(at: index)
                    }
                } else {
                    selectedOptions.append(optionTitle)
                }
                isChecked.toggle()
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 25))
            }
        }
        .onAppear {
            isChecked = selectedOptions.contains(optionTitle)
        }
    }
}
