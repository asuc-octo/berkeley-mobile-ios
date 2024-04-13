//
//  AlertDetailCard.swift
//  berkeley-mobile
//
//  Created by Aditi Telang on 4/12/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct AlertDetailCard: View {
    var typeColor: Color
    var notes: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            VStack {
                Spacer()
                alertCard
            }
        }
    }

    var alertCard: some View {
        HStack {
            Rectangle()
                .foregroundStyle(.orange)
                .frame(width: 17)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Robbery")
                    .font(.title2)
                    .bold()
                
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Button(action: {}) {
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack {
                                            Text("Two male subjects wearing dark clothing with ski masks..")
                                                .foregroundColor(.white)
                                                .font(.caption2)
                                                .padding([.leading, .trailing], 7)
                                        }
                                    }
                                    .frame(height: 28)
                                    .background(Rectangle().fill(Color.blue).cornerRadius(5)) // Background with rounded corners
                                }
                decorationsView
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            
        }
       
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(height: 200)
        .padding()
    }
    
    private var decorationsView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            
            Text("0.5 Distance from you")
                .font(.footnote)
        }
    }
}

struct AlertDetailCard_Previews: PreviewProvider {
    static var previews: some View {
        AlertDetailCard(typeColor: Color(CGColor(gray: 0, alpha: 1)), notes:"West Crescent \n04-12-2024\n06:30:00")

    }
}

