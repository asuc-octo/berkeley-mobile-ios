//
//  MapMakerDetailSwiftView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 3/11/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

// MARK: - MapMakerDetailSwiftView

struct MapMakerDetailSwiftView: View {

    var body: some View {
        ZStack {
            background
            
            HStack {
                colorAccentBar
                
                VStack {
                    headerView
                    Spacer()
                    descriptionView
                    Spacer()
                    infoRowView
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width: 400, height: 150)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Private Views
    private var background: some View {
        Color(.black)
            .opacity(0.4)
            .ignoresSafeArea()
    }
    
    private var colorAccentBar: some View {
        Rectangle()
            .fill(Color.purple)
            .frame(width: 10)
    }
    
    private var headerView: some View {
        HStack {
            Text("The Den")
                .font(.title)
                .bold()
                .padding([.leading], 25)
                .padding(.top, 10)
            Spacer()
            
            Button(action: {
                return
            }) {
                Image(systemName: "xmark")
                    .padding(.trailing, 10)
                    .foregroundStyle(Color.gray)
            }
        }
    }
    
    private var descriptionView: some View {
        HStack {
            Text("A retail Cal Dining location featuring a Peet Coffee & tea store, made- to-go order deli and bagels bar, smoothies, and grab-and-go items.")
                .font(Font(BMFont.light(15)))
                .padding(.leading, 20)
        }
    }
    
    private var infoRowView: some View {
        HStack {
            Spacer()
            Image(systemName: "clock")
            
            openStatusButton
            
            Spacer()
            locationInfoView
            Spacer()
            
            categoryView
            Spacer()
        }
    }
    
    private var openStatusButton: some View {
        Button(action : {
            return
        }) {
            Rectangle()
                .fill(Color.blue)
                .cornerRadius(300)
                .frame(width: 75, height: 25)
                .overlay(Text("Open")
                    .foregroundStyle(Color.white))
        }
    }
    
    private var locationInfoView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text("Residential Student Services Building")
                .font(Font(BMFont.light(15)))
        }
    }
    
    private var categoryView: some View {
        HStack {
            Image(systemName: "fork.knife")
            Text("<10")
                .font(Font(BMFont.light(15)))
        }
    }
}

#Preview {
    MapMakerDetailSwiftView()
}
