//
//  SearchDetailView.swift
//  bm-persona
//
//  Created by Shawn Huang on 3/21/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

import UIKit

class SearchDrawerViewController: DrawerViewController {
    
    // bottom cutoff position for middle position of the view
    // (e.g. bottom of overview card for library detail)
    var middleCutoffPosition: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupBackgroundView()
        setupGestures()
    }

}
