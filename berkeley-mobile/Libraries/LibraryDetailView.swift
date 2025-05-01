////
////  LibraryDetailView.swift
////  berkeley-mobile
////
////  Created by Hetvi Patel on 4/9/25.
////  Copyright © 2025 ASUC OCTO. All rights reserved.
////
//
import SwiftUI
import Firebase

struct LibraryDetailedView: View {
    let library: Library
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LibraryOverviewCardView(library: library)
                if library.weeklyHours != nil {
                    OpenTimesCardSwiftUIView(item: library)
                }
                BMActionButton(title: "Book a Study Room") {
                    if let url = URL(string: "https://berkeley.libcal.com") {
                        UIApplication.shared.open(url)
                    }
                }
                if let description = library.description {
                    DecriptionView(description: description)
                }
            }
            .padding()
        }
        .onAppear {
            Analytics.logEvent("opened_library", parameters: ["library": library.name])
        }
    }
}

struct LibraryOverviewCardView: View {
    let library: Library

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            LibraryInformationView(library: library)
            
            Spacer()
        
            
            VStack(alignment: .trailing, spacing: 10) {
                if let url = library.imageURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 180)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image("DoeGlade")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 180)
                        .clipped()
                }
            }
        }
        .padding(16)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.25), radius: 5)
    }
}
struct LibraryInformationView: View {
    let library: Library
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(library.name)
                .font(Font(BMFont.bold(24)))
                .foregroundStyle(Color.black)
                .lineLimit(3)
                .minimumScaleFactor(0.4)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                if let address = library.address {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.black)
                        Text(address)
                            .font(Font(BMFont.light(12)))
                            .foregroundColor(.black)
                    }
                }
                
                if let phoneNumber = library.phoneNumber {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.black)
                        Text(phoneNumber)
                            .font(Font(BMFont.light(12)))
                            .foregroundColor(.black)
                            .lineLimit(nil)
                    }
                }
            }
        }
    }
}

struct DecriptionView: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Description")
                .font(Font(BMFont.bold(16)))
            Text(description)
                .font(Font(BMFont.light(12)))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(BMColor.cardBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.25), radius: 5)
    }
}

#Preview {
    LibraryDetailedView(library: Library(
        name: "Doe Library",
        description: "A beautiful study space at the heart of campus.",
        address: "Doe Library, UC Berkeley",
        phoneNumber: "(510) 642-3333",
        weeklyHours: nil,
        weeklyByAppointment: [false, false, false, false, false, true, true],
        imageLink: nil,
        latitude: 37.8721,
        longitude: -122.2594))
}
