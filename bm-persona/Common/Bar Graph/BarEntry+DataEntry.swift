//
//  BarEntry+DataEntry.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit

/// The frames associated with a single bar
struct BarEntry {
    let origin: CGPoint
    let barWidth: CGFloat
    let barHeight: CGFloat
    let horizontalSpace: CGFloat
    let data: DataEntry
    
    var bottomTitleFrame: CGRect {
        return CGRect(x: origin.x - horizontalSpace / 2, y: origin.y + 9 + barHeight, width: barWidth + horizontalSpace, height: 11)
    }
    
    var barFrame: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: barWidth, height: barHeight)
    }
}

/// The data required for a single bar
struct DataEntry {
    let color: UIColor
    let height: CGFloat
    let bottomText: String
    /// if true, this bar is added on top of the previous bar in the graph
    var overlapping: Bool
    init(color: UIColor, height: CGFloat, bottomText: String, overlapping: Bool = false) {
        self.color = color
        self.height = height
        self.bottomText = bottomText
        self.overlapping = overlapping
    }
}
