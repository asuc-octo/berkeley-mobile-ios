//
//  MapMakerDetailSwiftView.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 3/11/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct MapMakerDetailSwiftView: View {
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.4)
                .ignoresSafeArea()
            
            HStack {
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: 10)
                
                VStack {
                    HStack {
                        Text("The Den")
                            .font(.title)
                            .bold()
                            .padding([.leading], 25)
                            .padding(.top, 10)
                        Spacer()
                        
                        Button {
                            return
                        } label: {
                            Image(systemName: "xmark")
                            .padding(.trailing, 10)
                            .foregroundStyle(Color.gray)
                        }
                       
                        
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("A retail Cal Dining location featuring a Peet Coffee & tea store, made- to-go order deli and bagels bar, smoothies, and grab-and-go items.")
                            .font(.system(size: 15, weight: .light))
                            .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Image(systemName: "clock")
                        
                        
                        Button {
                            return
                        } label: {
                            Rectangle()
                                .fill(Color.blue)
                                .cornerRadius(300)
                                .frame(width: 75, height: 25)
                                .overlay(Text("Open")
                                    .foregroundStyle(Color.white))
                        }
                        
                        
                        Spacer()
                        Image(systemName: "mappin.and.ellipse")
                        Text("Residential Student Services Building")
                            .font(.system(size: 15, weight: .light))
                        Spacer()
                        Image(systemName: "fork.knife")
                        Text("<10")
                        Spacer()
                        
                    }
                    
                }
                
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width:400, height: 150)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            
        }

    }
}

#Preview {
    MapMakerDetailSwiftView()
}
