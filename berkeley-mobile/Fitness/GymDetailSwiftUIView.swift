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
                    actionButton(title: "Learn More") {
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
                    Text(gym.name)
                        .font(Font(BMFont.bold(28)))
                        .foregroundColor(Color(BMColor.blackText))
                        .lineLimit(3)
                        .padding(.top, 8)
                    
                    Spacer(minLength: 80)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if let address = gym.address, !address.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color(BMColor.blackText))
                                    .frame(width: 16, height: 16)
                                
                                Text(address)
                                    .font(Font(BMFont.light(11)))
                                    .foregroundColor(Color(BMColor.blackText))
                                    .lineLimit(2)
                            }
                            .padding(.bottom, 1)
                        }
                        
                        HStack(spacing: 10) {
                            if let phoneNumber = gym.phoneNumber, !phoneNumber.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Color(BMColor.blackText))
                                        .frame(width: 16, height: 16)
                                    
                                    Text(phoneNumber)
                                        .font(Font(BMFont.light(11)))
                                        .foregroundColor(Color(BMColor.blackText))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            if let hasLocation = gym as? HasLocation, 
                               let distance = hasLocation.distanceToUser {
                                HStack(spacing: 3) {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(Color(BMColor.blackText))
                                        .frame(width: 16, height: 16)
                                    
                                    Text(String(format: "%.1f mi", distance))
                                        .font(Font(BMFont.light(11)))
                                        .foregroundColor(Color(BMColor.blackText))
                                }
                            }
                        }
                        
                    }
                }
                
                Spacer()
                
                if let imageURL = gym.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            Image("DoeGlade")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
                                )
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
                            // Default image on failure
                            Image("DoeGlade")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Default image when no image URL is available
                    Image("DoeGlade")
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
            .padding(8)
        }
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color(uiColor: .label).opacity(0.15), radius: 5, x: 0, y: 0)
    }
    
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Font(BMFont.medium(16)))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(BMColor.ActionButton.background))
                .cornerRadius(10)
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
    // Sample gym for preview
    let sampleGym = Gym(
        name: "RSF (Recreational Sports Facility)",
        description: "The Recreational Sports Facility (RSF) is UC Berkeley's largest fitness center, offering state-of-the-art equipment, group exercise classes, and various sports courts. Located at the heart of campus, it provides comprehensive fitness options for students and faculty.",
        address: "2301 Bancroft Way, Berkeley, CA 94720",
        phoneNumber: "(510) 111-2222",
        imageLink: nil,
        weeklyHours: nil,
        link: "https://recsports.berkeley.edu/rsf/"
    )
    
    // Randomly generated latitude and longitude
    sampleGym.latitude = 37.8687
    sampleGym.longitude = -122.2614
    
    return NavigationView {
        GymDetailSwiftUIView(gym: sampleGym)
    }
} 
