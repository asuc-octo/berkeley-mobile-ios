//
//  HomeSectionListRowView.swift
//  berkeley-mobile
//
//  Created by Baurzhan on 3/2/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

class HomeSectionListRowViewModel: ObservableObject {
    @Published var title = ""
    @Published var distance = 0.0
    @Published var image = UIImage(imageLiteralResourceName: "DoeGlade")
    
    func configureRow(with rowItem: SearchItem & HasLocation & HasImage) {
        withAnimation {
            title = rowItem.searchName
            distance = rowItem.distanceToUser ?? 0.0
            fetchImage(for: rowItem)
        }
    }
    
    private func fetchImage(for itemWithImage: HasImage) {
        if let itemImage = itemWithImage.image {
            image = itemImage
        } else if let url = itemWithImage.imageURL {
            ImageLoader.shared.getImage(url: url) { result in
                switch result {
                case .success(let image):
                    self.image = image
                default:
                    break
                }
            }
        }
    }
}

struct HomeSectionListRowView: View {
    @EnvironmentObject var viewModel: HomeSectionListRowViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .foregroundStyle(Color(BMColor.blackText))
                    .font(Font(BMFont.bold(18)))
                Spacer()
                distanceLabelView
            }
            .frame(height: 74)
            
            Spacer()
            
            imageView
        }
    }
    
    private var distanceLabelView: some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundStyle(Color(BMColor.blackText))
                .font(.system(size: 14))
            
            Text("\(viewModel.distance, specifier: "%.1f") mi")
                .foregroundStyle(Color(BMColor.blackText))
                .font(Font(BMFont.light(14)))
        }
    }
    
    private var imageView: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    let viewModel = HomeSectionListRowViewModel()
    let foothillDiningHall = DiningHall(name: "Foothill", address: nil, phoneNumber: nil, imageLink: "https://firebasestorage.googleapis.com/v0/b/berkeley-mobile.appspot.com/o/images%2FFoothill.jpg?alt=media&token=b645d675-6f51-45ea-99f7-9b36576e14b7", shifts: MealMap(), hours: nil, latitude: 37.87538, longitude: -122.25612109999999)
    viewModel.configureRow(with: foothillDiningHall)
    
    return HomeSectionListRowView()
        .environmentObject(viewModel)
        .padding(40)
}
