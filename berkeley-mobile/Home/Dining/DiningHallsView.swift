//
//  DiningHallsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct DiningHallsView: View {
    @Environment(HomeDrawerPinViewModel.self) private var homeDrawerPinViewModel
    @Environment(DiningHallsViewModel.self) private var viewModel
    
    let mapViewController: MapViewController
    var selectionHandler: ((BMDiningHall) -> Void)?
    
    var body: some View {
        if viewModel.isFetching {
            ProgressView("LOADING")
            Spacer()
        } else {
            BMHomeSectionListView(sectionType: .dining, items: viewModel.diningHalls, mapViewController: mapViewController) { selectedDiningHall in
                selectionHandler?(selectedDiningHall as! BMDiningHall)
            } swipeActionsContent: { diningHall in
                if !homeDrawerPinViewModel.pinnedRowItemIDSet.contains(diningHall.docID) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            homeDrawerPinViewModel.addPinnedRowItem(withID: diningHall.docID)
                        }
                    }) {
                        Label("Pin", systemImage: "pin.fill")
                    }
                    .tint(.yellow)
                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            homeDrawerPinViewModel.removePinnedRowItem(withID: diningHall.docID)
                        }
                    }) {
                        Label("Unpin", systemImage: "pin.slash.fill")
                    }
                    .tint(.yellow)
                }
            }
        }
    }
}
