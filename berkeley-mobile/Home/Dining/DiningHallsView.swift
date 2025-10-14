//
//  DiningHallsView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct DiningHallsView: View {
    @Environment(DiningHallsViewModel.self) private var viewModel
    
    let mapViewController: MapViewController
    
    var selectionHandler: ((BMDiningHall) -> Void)?
    
    var body: some View {
        if viewModel.isFetching {
            ProgressView("LOADING")
        } else {
            BMHomeSectionListView(sectionType: .dining, items: viewModel.diningHalls, mapViewController: mapViewController) { selectedDiningHall in
                selectionHandler?(selectedDiningHall as! BMDiningHall)
            }
        }
    }
}
