//
//  Sort.swift
//  bm-persona
//
//  Created by Shawn Huang on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

protocol TableFunction {
    var label: String { get set }
}

struct Sort<T>: TableFunction {
    
    var label: String
    var sort: ((T, T) -> Bool)
  
}
