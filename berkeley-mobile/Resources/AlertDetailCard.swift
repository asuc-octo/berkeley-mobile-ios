// AlertDetailCard.swift
// berkeley-mobile
// Created by Aditi Telang on 4/12/24.
import SwiftUI

struct AlertDetailCard: View {
    var typeColor: Color
    var notes: String
    
    @State private var isDescriptionExpanded: Bool = false
    
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
                                Button(action: {
                    self.isDescriptionExpanded.toggle()
                }) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            Text(isDescriptionExpanded ? "Detailed description about the robbery incident, including possible suspects, last seen locations, and advised actions for public safety. Tap to see less." : "Description of Incident")
                                .foregroundColor(.white)
                                .font(.caption2)

                                .padding([.leading, .trailing], 7)
                                .animation(.easeInOut, value: isDescriptionExpanded)
                        }
                    }
                    .frame(minHeight: isDescriptionExpanded ? 60 : 28)
                    .background(Rectangle().fill(Color.gray).cornerRadius(1))
                }
                
                decorationsView
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(height: isDescriptionExpanded ? 240 : 200)
        .padding()
    }
    
    private var decorationsView: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text("0.5 mi Distance from you")
                .font(.footnote)
        }
    }
}

struct AlertDetailCard_Previews: PreviewProvider {
    static var previews: some View {
        AlertDetailCard(typeColor: Color(CGColor(gray: 0, alpha: 1)), notes:"West Crescent \n04-12-2024\n06:30:00")
    }
}
