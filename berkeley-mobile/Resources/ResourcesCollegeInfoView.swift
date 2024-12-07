//
//  ResourcesCollegeInfoView.swift
//  berkeley-mobile
//
//  Created by Sahana Bharadwaj on 10/24/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI


struct ResourcesCollegeInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            imageDetailedTextView
            addressPlacemarkView
            timeDayView
            Spacer()
        }
        .font(Font(BMFont.regular(14)))
        .padding()
    }
    
    private var imageDetailedTextView: some View {
        HStack {
            Image("Gilman Hall")
                .resizable()
                .scaledToFit()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
        }
    }
    
    private var addressPlacemarkView: some View {
        HStack {
            Image("Placemark")
            Text("121 Gilman Hall, Berkeley")
        }
    }
    
    private var timeDayView: some View {
        HStack(spacing: 16) {
            Text("Monday – Friday")
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("8:30 AM - 12:00 PM")
                Text("1:00 PM - 5:00 PM")
            }
            .font(.subheadline)
            
            Button(action: {}) {
                Text("Open")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .background(.blue)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ResourcesCollegeInfoView()
}
