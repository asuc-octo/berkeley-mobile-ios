//
//  GymDetailView.swift
//
//  Created by Yihang Chen on 4/9/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct CategoryOverviewCard: View {
    let category: SearchItem & HasLocation & HasImage
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading) {
                TitleView(name: category.name)
                
                Spacer(minLength: 20)
                
                ContactInfoView(category: category)
            }
            
            Spacer()
            
            ImageView(imageURL: category.imageURL)
        }
        .padding(12)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color(uiColor: .label).opacity(0.15), radius: 5, x: 0, y: 0)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    struct TitleView: View {
        let name: String
        
        var body: some View {
            Text(name)
                .font(Font(BMFont.bold(23)))
                .foregroundColor(Color(BMColor.blackText))
                .lineLimit(3)
                .padding(.top, 8)
        }
    }
    
    struct ContactInfoView: View {
        let category: SearchItem & HasLocation
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                if let address = category.address, !address.isEmpty {
                    ContactInfoRow(
                        iconName: "location.fill",
                        text: address,
                        lineLimit: nil
                    )
                }
                
                if let hasPhone = category as? HasPhoneNumber, 
                   let phoneNumber = hasPhone.phoneNumber,
                   !phoneNumber.isEmpty {
                    ContactInfoRow(
                        iconName: "phone.fill",
                        text: phoneNumber
                    )
                }
                
                if let distance = category.distanceToUser {
                    ContactInfoRow(
                        iconName: "figure.walk",
                        text: String(format: "%.1f miles", distance)
                    )
                }
            }
            .foregroundColor(Color(BMColor.blackText))
        }
    }
    
    struct ContactInfoRow: View {
        let iconName: String
        let text: String
        var lineLimit: Int? = 1
        
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .frame(width: 18, height: 18)
                
                Text(text)
                    .font(Font(BMFont.light(12)))
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    struct ImageView: View {
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
            Image(uiImage: Constants.doeGladeImage)
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
}

struct GymDetailView: View {
    @Environment(\.openURL) private var openURL

    let gym: Gym
    init(gym: Gym) {
        self.gym = gym
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CategoryOverviewCard(category: gym)
                
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
        GymDetailView(gym: sampleGym)
    }
} 
