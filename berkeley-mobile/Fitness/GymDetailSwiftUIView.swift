//
//  GymDetailSwiftUIView.swift
//
//  Created by Yihang Chen on 4/9/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI
import Firebase

struct GymDetailSwiftUIView: View {
    @Environment(\.openURL) private var openURL

    let gym: Gym
    init(gym: Gym) {
        self.gym = gym
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                overviewCard
                
                if gym.weeklyHours != nil {
                    OpenTimesCardSwiftUIView(item: gym)
                }
                
                if let website = gym.website {
                    BMActionButton(title: "Learn More") {
                        openURL(website)
                    }
                }
                
                if let description = gym.description, !description.isEmpty {
                    descriptionCard(description: description)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
        .navigationTitle(gym.name)
        .onAppear {
            Analytics.logEvent("opened_gym", parameters: ["gym": gym.name])
        }
    }
    
    private var overviewCard: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading) {
                    GymTitleView(name: gym.name)
                    
                    Spacer(minLength: 20)
                    
                    GymContactInfoView(gym: gym)
                }
                
                Spacer()
                
                GymImageView(imageURL: gym.imageURL)
            }
            .padding(8)
        }
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color(uiColor: .label).opacity(0.15), radius: 5, x: 0, y: 0)
    }
    
    private struct GymTitleView: View {
        let name: String
        
        var body: some View {
            Text(name)
                .font(Font(BMFont.bold(28)))
                .foregroundColor(Color(BMColor.blackText))
                .lineLimit(3)
                .padding(.top, 8)
        }
    }
    
    private struct GymContactInfoView: View {
        let gym: Gym
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                if let address = gym.address, !address.isEmpty {
                    ContactInfoRow(
                        iconName: "location.fill",
                        text: address,
                        lineLimit: nil
                    )
                }
                
                if let phoneNumber = gym.phoneNumber, !phoneNumber.isEmpty {
                    ContactInfoRow(
                        iconName: "phone.fill",
                        text: phoneNumber
                    )
                }
                
                if let hasLocation = gym as? HasLocation, 
                   let distance = hasLocation.distanceToUser {
                    ContactInfoRow(
                        iconName: "figure.walk",
                        text: String(format: "%.1f miles", distance)
                    )
                }
            }
        }
    }
    
    private struct ContactInfoRow: View {
        let iconName: String
        let text: String
        var lineLimit: Int? = 1
        
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .foregroundColor(Color(BMColor.blackText))
                    .frame(width: 18, height: 18)
                
                Text(text)
                    .font(Font(BMFont.light(14)))
                    .foregroundColor(Color(BMColor.blackText))
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private struct GymImageView: View {
        let imageURL: URL?
        
        var body: some View {
            if let imageURL = imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        defaultImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
                            )
                    case .failure:
                        defaultImage
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                defaultImage
            }
        }
        
        private var defaultImage: some View {
            Image(Constants.doeGladeImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
                )
        }
    }
    
    private func descriptionCard(description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(Font(BMFont.bold(16)))
                .foregroundColor(Color(BMColor.blackText))
            
            Text(description)
                .font(Font(BMFont.light(12)))
                .foregroundColor(Color(BMColor.blackText))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleGym = Gym(
        name: "RSF (Recreational Sports Facility)",
        description: "The Recreational Sports Facility (RSF) is UC Berkeley's largest fitness center, offering state-of-the-art equipment, group exercise classes, and various sports courts. Located at the heart of campus, it provides comprehensive fitness options for students and faculty.",
        address: "2301 Bancroft Way, Berkeley, CA 94720",
        phoneNumber: "(510) 111-2222",
        imageLink: nil,
        weeklyHours: nil,
        link: "https://recsports.berkeley.edu/rsf/"
    )
    
    sampleGym.latitude = 37.8687
    sampleGym.longitude = -122.2614
    
    return NavigationView {
        GymDetailSwiftUIView(gym: sampleGym)
    }
} 
