//
//  BarGraph.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

/// A view containing a horizontally scrolling bar graph with rounded rectangle entries
class BarGraph: UIView {
    private let mainLayer: CALayer = CALayer()
    /// Horizontal scroll view in case there are many entries
    private let scrollView: UIScrollView = UIScrollView()
    private var barWidth: CGFloat = 16
    private var horizontalSpace: CGFloat = 1
    private let barRadius: CGFloat = 7
    /// Space below the bars to allow for text
    private let bottomSpace: CGFloat = 30.0
    
    /// The data for each bar to be included in the graph. Changing this variable will update the graph.
    public var dataEntries: [DataEntry] = [] {
        didSet {
            setBarEntries()
        }
    }
    /// The bars included in the graph
    private var barEntries: [BarEntry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            scrollView.contentSize = CGSize(width: computeContentWidth(), height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            for bar in barEntries {
                addBar(bar)
            }
        }
    }
    
    init(frame: CGRect = CGRect.zero, barWidth: CGFloat = 16, horizontalSpace: CGFloat = 1) {
        super.init(frame: frame)
        self.barWidth = barWidth
        self.horizontalSpace = horizontalSpace
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBarEntries()
    }
    
    /**
     Adds a bar to the graph (including rounded rectangle and text below)
     - parameter bar: the data needed to add the bar
     */
    private func addBar(_ bar: BarEntry) {
        mainLayer.addRoundedRectangleLayer(frame: bar.barFrame, cornerRadius: barRadius, color: bar.data.color.cgColor)
        mainLayer.addTextLayer(frame: bar.bottomTitleFrame, color: BMColor.blackText.cgColor, fontSize: 10, text: bar.data.bottomText)
    }
    
    /// Computes the total width necessary to include all entries
    private func computeContentWidth() -> CGFloat {
        return (barWidth + horizontalSpace) * CGFloat(dataEntries.count) + horizontalSpace
    }
    
    /// Updates the bar entries based on the data entries
    private func setBarEntries() {
        var result: [BarEntry] = []
        for entry in dataEntries {
            let entryHeight = entry.height * (frame.height - bottomSpace)
            let xPosition: CGFloat = horizontalSpace + CGFloat(entry.index) * (barWidth + horizontalSpace)
            let yPosition = frame.height - bottomSpace - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BarEntry(origin: origin, barWidth: barWidth, barHeight: entryHeight, horizontalSpace: horizontalSpace, data: entry)
            result.append(barEntry)
        }
        barEntries = result
    }
}
