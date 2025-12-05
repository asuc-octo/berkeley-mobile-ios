//
//  LibrariesView.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/7/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import SwiftUI

struct LibrariesView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    let mapViewController: MapViewController
    
    var selectionHandler: ((BMLibrary) -> Void)?
    
    var body: some View {
        BMHomeSectionListView(sectionType: .study, items: homeViewModel.libraries, mapViewController: mapViewController) { selectedLibrary in
            selectionHandler?(selectedLibrary as! BMLibrary)
        } swipeActionsContent: {_ in }
    }
}
