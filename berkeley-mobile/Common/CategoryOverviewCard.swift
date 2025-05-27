//
//  CategoryOverviewCard.swift
//  berkeley-mobile
//
//  Created by Yihang Chen on 5/1/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct BMContactInfoRow: View {
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

struct BMCategoryOverviewCard: View {
    let category: SearchItem & HasLocation & HasImage
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading) {
                titleView
                
                Spacer(minLength: 20)
                
                contactInfoView
            }
            
            Spacer()
            
            imageView
        }
        .padding(12)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color(uiColor: .label).opacity(0.15), radius: 5, x: 0, y: 0)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private var titleView: some View {
        Text(category.name)
            .font(Font(BMFont.bold(23)))
            .foregroundColor(Color(BMColor.blackText))
            .lineLimit(3)
            .padding(.top, 8)
    }
    
    private var contactInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let address = category.address, !address.isEmpty {
                BMContactInfoRow(
                    iconName: "location.fill",
                    text: address,
                    lineLimit: nil
                )
            }
            
            if let hasPhone = category as? HasPhoneNumber, 
               let phoneNumber = hasPhone.phoneNumber,
               !phoneNumber.isEmpty {
                BMContactInfoRow(
                    iconName: "phone.fill",
                    text: phoneNumber
                )
            }
            
            if let distance = category.distanceToUser {
                BMContactInfoRow(
                    iconName: "figure.walk",
                    text: String(format: "%.1f miles", distance)
                )
            }
        }
        .foregroundColor(Color(BMColor.blackText))
    }
    
    private var imageView: some View {
        Group {
            if let imageURL = category.imageURL {
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