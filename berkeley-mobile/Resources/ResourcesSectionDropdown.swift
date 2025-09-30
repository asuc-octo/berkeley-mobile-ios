//
//  ResourcesSectionDropdown.swift
//  berkeley-mobile
//
//  Created by yhc on 2/28/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI
import StoreKit

struct ResourcesSectionDropdown<Content: View>: View {
    let title: String
    let accentColor: Color
    let content: Content
    
    @State private var isExpanded = false
    
    init(title: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.accentColor = accentColor
        self.content = content()
    }
    
    private var headerButton: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack {
                Text(title)
                    .font(Font(BMFont.bold(25)))
                    .foregroundColor(Color.primary)
                    .padding(.vertical, 16)
                    .multilineTextAlignment(.leading)
                
                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .fontWeight(.heavy)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .padding(.trailing, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(BMColor.cardBackground))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            headerButton
            if isExpanded {
                Divider()
                content
                    .padding(.vertical, 8)
            }
        }
        .background(Color(BMColor.cardBackground))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}


// MARK: - ResourceItemView

struct ResourceItemView: View {
    var resource: BMResource
    var accentColor: Color?

    private static let colorPalette: [Color] = [
        .blue,
        .red,
        .green,
        .purple,
        .orange,
        Color(red: 0.4, green: 0.65, blue: 0.9),   // Light blue
        Color(red: 0.9, green: 0.4, blue: 0.4),    // Coral
        Color(red: 0.5, green: 0.8, blue: 0.5),    // Mint 
        Color(red: 0.7, green: 0.4, blue: 0.7),    // Violet purple
        Color(red: 0.95, green: 0.6, blue: 0.1)    // Golden
    ]
    
    private var colorForResource: Color {
        if let providedColor = accentColor {
            return providedColor
        }

        let nameHash = resource.name.hash
        let colorIndex = abs(nameHash) % ResourceItemView.colorPalette.count
        return ResourceItemView.colorPalette[colorIndex]
    }
    
    @State private var isExpanded = false
    @State private var isPresentingWebView = false
    
    private var coloredBar: some View {
        Rectangle()
            .fill(colorForResource)
            .frame(width: 8)  
            .cornerRadius(3)
    }
    
    private var headerButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(resource.name)
                    .font(Font(BMFont.regular(17)))
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.vertical, 8)
                    .multilineTextAlignment(.leading)
                
                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .padding(.trailing, 16)
            }
        }
        .background(Color(BMColor.cardBackground))
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isPresentingWebView.toggle()
                ReviewPrompter.shared.incSuccessfulEvent()
//                ReviewPrompter.shared.resetForTesting()
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Visit Website")
                }
                .foregroundStyle(.blue)
                .font(Font(BMFont.regular(14)))
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(BMColor.cardBackground).opacity(0.8))
    }
 
    private var websiteView: some View {
        Group {
            if let url = resource.url {
                SafariWebView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    var body: some View {
        HStack {
            coloredBar
            
            VStack(alignment: .leading) {
                headerButton
                if isExpanded {
                    expandedContent
                }
            }
        }
        .background(Color(BMColor.cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1.8)
        )
        .cornerRadius(10)
        .padding(.vertical, 4)
        .fullScreenCover(isPresented: $isPresentingWebView) {
            websiteView
        }
    }
}
