//
//  SearchDetailView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/21/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

// Additional detail drawers to show details for dining halls, libraries, etc.
class SearchDrawerViewController: DrawerViewController {
    
    // cutoff for the 'middle' position of the drawer
    // (e.g. for the library detail drawer, this is set to be just below the overview card)
    var middleCutoffPosition: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // default to middle position when created
        currState = .middle
        prevState = .middle
    }
    
}
