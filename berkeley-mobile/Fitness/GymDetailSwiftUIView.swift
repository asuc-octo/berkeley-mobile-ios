//
//  GymDetailSwiftUIView.swift
//
//  Created by Yihang Chen on 4/9/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI
import Firebase

// Remove the invalid type alias
// typealias GymDetailView = GymDetailSwiftUIView

struct GymDetailSwiftUIView: View {
    let gym: Gym
    
    @Environment(\.openURL) private var openURL
    
    // Allow initialization with just a gym to match existing GymDetailView interface
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
    
    // Overview card showing image, name, address, and other basic info
    private var overviewCard: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                // Left column with title and details
                VStack(alignment: .leading) {
                    // Title at the top
                    Text(gym.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(BMColor.blackText))
                        .lineLimit(3)
                        .padding(.top, 8)
                    
                    Spacer(minLength: 80)
                    
                    // Contact info at the bottom
                    VStack(alignment: .leading, spacing: 12) {
                        // Address
                        if let address = gym.address, !address.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 16, height: 16)
                                
                                Text(address)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                            }
                            .padding(.bottom, 1)
                        }
                        
                        // Phone and distance on the same line
                        HStack(spacing: 10) {
                            // Phone number
                            if let phoneNumber = gym.phoneNumber, !phoneNumber.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(phoneNumber)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            
                           
                            
                            // Distance
                            if let hasLocation = gym as? HasLocation, 
                               let distance = hasLocation.distanceToUser {
                                HStack(spacing: 3) {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.gray)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(String(format: "%.1f mi", distance))
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                    }
                }
                
                Spacer()
                
                // Image on the right
                if let imageURL = gym.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 220)
                                .foregroundColor(.gray.opacity(0.3))
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 220)
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
    }
    
    
    // Custom action button (like "Learn More")
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    // Description card showing the gym description
    private func descriptionCard(description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(BMColor.blackText))
            
            Text(description)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Color(BMColor.blackText))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        
    }
}

// A SwiftUI preview for the GymDetailView
#Preview {
    // Create a sample gym for preview
    let sampleGym = Gym(
        name: "RSF (Recreational Sports Facility)",
        description: "The Recreational Sports Facility (RSF) is UC Berkeley's largest fitness center, offering state-of-the-art equipment, group exercise classes, and various sports courts. Located at the heart of campus, it provides comprehensive fitness options for students and faculty.",
        address: "2301 Bancroft Way, Berkeley, CA 94720",
        phoneNumber: "(510) 111-2222",
        imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FRSF.jpg?alt=media&token=b645d675-6f51-45ea-99f7-9b36576e14b7",
        weeklyHours: nil,
        link: "https://recsports.berkeley.edu/rsf/"
    )
    
    // Set a fake distance
    sampleGym.latitude = 37.8687
    sampleGym.longitude = -122.2614
    
    return NavigationView {
        GymDetailSwiftUIView(gym: sampleGym)
    }
} 
