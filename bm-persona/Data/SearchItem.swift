//
//  SearchItem.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

protocol SearchItem {
    
    var searchName: String { get }
    var location: (Double, Double) { get }
    var locationName: String { get }
    
}