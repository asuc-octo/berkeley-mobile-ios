//
//  BarEntry+DataEntry.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics.CGGeometry

struct BarEntry {
    let origin: CGPoint
    let barWidth: CGFloat
    let barHeight: CGFloat
    let horizontalSpace: CGFloat
    let data: DataEntry
    
    var bottomTitleFrame: CGRect {
        return CGRect(x: origin.x - horizontalSpace/2, y: origin.y + 10 + barHeight, width: barWidth + horizontalSpace, height: 22)
    }
    
    var textValueFrame: CGRect {
        return CGRect(x: origin.x - horizontalSpace/2, y: origin.y - 30, width: barWidth + horizontalSpace, height: 22)
    }
    
    var barFrame: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: barWidth, height: barHeight)
    }
}

struct DataEntry {
    let color: UIColor
    let height: CGFloat
    let bottomText: String
}
