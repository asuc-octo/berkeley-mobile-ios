//
//  HomeDrawerSectionListView.swift
//  berkeley-mobile
//
//  Created by Iyu Lin on 2025/4/9.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct HomeDrawerSectionListView<Item: Identifiable & SearchItem & HasLocation & HasImage>: View {
 
    let items: [Item]
    
    var body: some View {
        List {
            ForEach(items) { item in
                let viewModel =
                HomeSectionListRowViewModel()
                HomeSectionListRowView()
                    .environmentObject(viewModel)
                    .onAppear {
                        viewModel.configureRow(with: item)
                    }
                    .padding() 
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .tertiarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
            }
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    
    struct MockDiningHall: Identifiable, SearchItem, HasLocation, HasImage {
        var icon: UIImage?
        
        var latitude: Double?
        
        var longitude: Double?
        
        var address: String?
        
        var imageURL: URL?
        
        let id = UUID()
        let name: String
        var searchName: String { name }
        var distanceToUser: Double? = 0.0
    }

    let mockData = [
        MockDiningHall(name: "Cafe 3"),
        MockDiningHall(name: "Clark Kerr"),
        MockDiningHall(name: "Crossroads"),
        MockDiningHall(name: "Foothill")
    ]

    return HomeDrawerSectionListView(
        items: mockData
    )
}
