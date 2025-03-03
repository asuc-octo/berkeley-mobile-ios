//
//  ResourcesSectionDropdown.swift
//  berkeley-mobile
//
//  Created by yhc on 2/28/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI


// MARK: The main section dropdown

struct ResourcesSectionDropdown<Content: View>: View {
    let title: String
    let accentColor: Color
    let content: Content
    
    @State private var isExpanded: Bool = false
    
    init(title: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                isExpanded.toggle()
                }) {
                HStack {
                    // Title
                    Text(title)
                        .font(Font(BMFont.bold(25)))
                        .foregroundColor(Color.primary)
                        .padding(.vertical, 16)
                    
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
            
            // Content
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


// MARK: Individual resource item that can expand to show its own content

struct ResourceItemView: View {
    var resource: BMResource
    var accentColor: Color?
    
    // Color palette for resources
    private static let colorPalette: [Color] = [
        .blue,
        .red,
        .green,
        .purple,
        .orange,
        Color(red: 0.4, green: 0.65, blue: 0.9),   // Light blue
        Color(red: 0.9, green: 0.4, blue: 0.4),    // Coral
        Color(red: 0.5, green: 0.8, blue: 0.5),    // Mint 
        Color(red: 0.7, green: 0.4, blue: 0.7),    // purple
        Color(red: 0.95, green: 0.6, blue: 0.1)    // Golden
    ]
    
    // get a color based on the resource name
    private var colorForResource: Color {
        if let providedColor = accentColor {
            return providedColor
        }
        
        // ensure the same resource always gets the same color
        let nameHash = resource.name.hash
        let colorIndex = abs(nameHash) % ResourceItemView.colorPalette.count
        return ResourceItemView.colorPalette[colorIndex]
    }
    
    @State private var isExpanded: Bool = false
    @State private var isPresentingWebView = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Colored vertical bar
            Rectangle()
                .fill(colorForResource)
                .frame(width: 8)  
                .cornerRadius(3)  
            
            VStack(alignment: .leading, spacing: 0) {
                // Header button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        // Resource name
                        Text(resource.name)
                            .font(Font(BMFont.regular(17)))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.leading, 16)
                            .padding(.vertical, 8)
                        
                        Spacer()
                        
                        // Chevron - right when collapsed, down when expanded
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .padding(.trailing, 16)
                    }
                }
                .background(Color(BMColor.cardBackground))
                
                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        // Description
                        Text("Details for \(resource.name)")
                            .font(Font(BMFont.regular(14)))
                            .padding(.bottom, 4)
                        
                        // Website link
                        Button(action: {
                            isPresentingWebView.toggle()
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
            }
        }
        .background(Color(BMColor.cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(10)
        .padding(.vertical, 4)
        .fullScreenCover(isPresented: $isPresentingWebView) {
            if let url = resource.url {
                SafariWebView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
