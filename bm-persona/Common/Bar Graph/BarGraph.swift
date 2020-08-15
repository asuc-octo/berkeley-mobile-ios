//
//  BarGraph.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/12/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class BarGraph: UIView {
    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    private var barWidth: CGFloat = 16
    private var horizontalSpace: CGFloat = 1
    private let barRadius: CGFloat = 7
    private let bottomSpace: CGFloat = 30.0
    
    public var dataEntries: [DataEntry] = [] {
        didSet {
            setBarEntries()
        }
    }
    private var barEntries: [BarEntry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            scrollView.contentSize = CGSize(width: computeContentWidth(), height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            for (index, entry) in barEntries.enumerated() {
                addEntry(index: index, entry: entry)
            }
        }
    }
    
    init(frame: CGRect = CGRect.zero, barWidth: CGFloat = 16, horizontalSpace: CGFloat = 1) {
        super.init(frame: frame)
        self.barWidth = barWidth
        self.horizontalSpace = horizontalSpace
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
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
    
    private func addEntry(index: Int, entry: BarEntry) {
        mainLayer.addRoundedRectangleLayer(frame: entry.barFrame, cornerRadius: barRadius, color: entry.data.color.cgColor)
        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: Color.blackText.cgColor, fontSize: 10, text: entry.data.bottomText)
    }
    
    private func computeContentWidth() -> CGFloat {
        return (barWidth + horizontalSpace) * CGFloat(dataEntries.count) + horizontalSpace
    }
    
    private func setBarEntries() {
        var result: [BarEntry] = []
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.height) * (frame.height - bottomSpace)
            let xPosition: CGFloat = horizontalSpace + CGFloat(index) * (barWidth + horizontalSpace)
            let yPosition = frame.height - bottomSpace - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BarEntry(origin: origin, barWidth: barWidth, barHeight: entryHeight, horizontalSpace: horizontalSpace, data: entry)
            result.append(barEntry)
        }
        barEntries = result
    }
}
