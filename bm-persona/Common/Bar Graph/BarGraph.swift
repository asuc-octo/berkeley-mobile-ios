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
    private let presenter = BarGraphPresenter(barWidth: 16, space: 1)
    private let barRadius: CGFloat = 7
    
    /// An array of bar entries. Each BasicBarEntry contain information about line segments, curved line segments, positions and frames of all elements on a bar.
    private var barEntries: [BarEntry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            scrollView.contentSize = CGSize(width: presenter.computeContentWidth(), height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            for (index, entry) in barEntries.enumerated() {
                showEntry(index: index, entry: entry)
            }
        }
    }
    
    func updateDataEntries(dataEntries: [DataEntry]) {
        self.presenter.dataEntries = dataEntries
        self.barEntries = self.presenter.computeBarEntries(viewHeight: self.frame.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateDataEntries(dataEntries: presenter.dataEntries)
    }
    
    private func showEntry(index: Int, entry: BarEntry) {
        let cgColor = entry.data.color.cgColor
        
        mainLayer.addRoundedRectangleLayer(frame: entry.barFrame, cornerRadius: barRadius, color: cgColor)
        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: Color.blackText.cgColor, fontSize: 10, text: entry.data.bottomText)
    }
}
