//
//  ResourcesCollegeInfoView.swift
//  berkeley-mobile
//
//  Created by Sahana Bharadwaj on 10/24/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

import SwiftUI

struct ResourcesCollegeInfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Image("Gilman Hall")
                        .resizable()
                        .scaledToFit()
                        .padding(.leading)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                        .font(Font.custom("BMFont", size:14))
                        .padding(.trailing)
                    Spacer()
                }
            }
            
            HStack {
                Image("Placemark")
                    .padding(.leading)
                Text("121 Gilman Hall, Berkeley")
                    .font(Font.custom("BMFont", size:16))
                Spacer()
            }
            
            HStack(spacing: 16) {
                Text("Monday – Friday")
                    .font(Font.custom("BMFont", size:14))
                    .padding(.leading)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("8:30 AM - 12:00 PM").font(Font.custom("BMFont", size:14))
                    Text("1:00 PM - 5:00 PM").font(Font.custom("BMFont", size:14))
                }
                .font(.subheadline)
                Button(action: {}) {
                    Text("Open")
                        .font(Font.custom("BMFont", size:14))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                
            }
            .padding(.horizontal)
            
            HStack {
                Image("Gilman Map")
                    .resizable()
                    .scaledToFit()
                    .padding(.all)
            }
            
            HStack {
                Text("Undergraduate    Graduate")
                    .font(Font.custom("BMFont", size:16))
                    .padding(.leading)
                Spacer()
            }
            Spacer()
        }
    }
}

struct ResourcesCollegeInfoView_Preview: PreviewProvider {
    static var previews: some View {
        ResourcesCollegeInfoView()
    }
}
