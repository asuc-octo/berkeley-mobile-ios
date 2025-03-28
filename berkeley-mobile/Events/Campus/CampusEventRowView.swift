//
//  CampusEventRowView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 3/18/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

class CampusEventRowViewModel: ObservableObject {
    @Published var title = ""
    @Published var timeText = ""
    @Published var locationText = ""
    @Published var image = Constants.doeGladeImage
    
    func configure(with entry: EventCalendarEntry) {
        title = entry.name
        timeText = entry.dateString
        locationText = entry.location ?? ""
        entry.fetchImage { image in
            guard let image else {
                return
            }
            self.image = image
        }
    }
}

struct CampusEventRowView: View {
    @EnvironmentObject var viewModel: CampusEventRowViewModel
    
    private let imageWidthAndHeight: CGFloat = 110
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(Font(BMFont.bold(15)))
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.timeText)
                        .fontWeight(.semibold)
                    Text(viewModel.locationText)
                }
                .fontWeight(.light)
            }
            .font(Font(BMFont.regular(11)))
            .frame(height: imageWidthAndHeight)
            
            Spacer()
            
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(width: imageWidthAndHeight, height: imageWidthAndHeight)
                .clipShape(.rect(cornerRadius: 12))
        }
        .padding(.vertical, 6)
        .frame(height: 150)
    }
}

#Preview {
    let viewModel = CampusEventRowViewModel()
    let entry = EventCalendarEntry(name: "Exhibit: Amy Tan’s Backyard Birds", date: Date(), end: Date(), descriptionText: "The Backyard Bird Chronicles is a series of drawings by Amy Tan that contributed to her New York Times bestselling book of the same name. The resulting whimsical pictures capture the birds’ quirks, their personalities, their humor, and their dramas.", location: "The Bancroft Library Gallery", imageURL: "https://events.berkeley.edu/live/image/gid/139/width/200/height/200/crop/1/src_region/0,0,1535,2048/9842_Amytanimage.rev.1738954493.jpg", sourceLink: "https://events.berkeley.edu/events/event/290926-exhibit-amy-tans-backyard-birds")
    viewModel.configure(with: entry)
    
    return CampusEventRowView()
        .padding()
        .environmentObject(viewModel)
}
