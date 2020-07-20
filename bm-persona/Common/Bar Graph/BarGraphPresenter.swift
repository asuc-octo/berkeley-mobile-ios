//
//  BarGraphPresenter.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

import Foundation
import CoreGraphics.CGGeometry

class BarGraphPresenter {
    let barWidth: CGFloat
    let space: CGFloat
    private let bottomSpace: CGFloat = 30.0
    
    var dataEntries: [DataEntry] = []
    
    init(barWidth: CGFloat = 40, space: CGFloat = 20) {
        self.barWidth = barWidth
        self.space = space
    }
    
    func computeContentWidth() -> CGFloat {
        return (barWidth + space) * CGFloat(dataEntries.count) + space
    }
    
    func computeBarEntries(viewHeight: CGFloat) -> [BarEntry] {
        var result: [BarEntry] = []
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.height) * (viewHeight - bottomSpace)
            let xPosition: CGFloat = space + CGFloat(index) * (barWidth + space)
            let yPosition = viewHeight - bottomSpace - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BarEntry(origin: origin, barWidth: barWidth, barHeight: entryHeight, space: space, data: entry)
            
            result.append(barEntry)
        }
        return result
    }
}
