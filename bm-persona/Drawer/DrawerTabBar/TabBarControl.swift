//
//  TabBarControl.swift
//  TabBarPoC
//
//  Created by Kevin Hu on 10/25/19.
//  Copyright © 2019 hu. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol TabBarControlDelegate {
    func tabBarControl(_ tabBarControl: TabBarControl, didChangeValue value: Int)
}

// MARK: - TabBarControl

class TabBarControl: UISegmentedControl {
    
    open var delegate: TabBarControlDelegate?
    
    private var indicator: UIView!
    private var indicatorHeight: CGFloat!
    
    private var maxWidth: CGFloat!
    private var widths: [CGFloat]!
    
    // Updates after animation completes
    open var index: Int! = 0 {
        didSet {
            selectedSegmentIndex = index
            updateIndicator()
        }
    }
    open var progress: Double! = 0 {
        didSet {
            updateIndicator()
        }
    }
    
    override var alpha: CGFloat {
        get { return 1.0 }
        set { }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
    }
    
    init(frame: CGRect, barHeight: CGFloat, barColor: UIColor) {
        super.init(frame: frame)
        
        setBackgroundImage(UIImage().resized(size: frame.size), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage().resized(size: frame.size), for: .normal, barMetrics: .default)
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font: Font.bold(18),
            NSAttributedString.Key.foregroundColor: Color.secondaryText
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: Color.primaryText
        ], for: .selected)
        
        self.apportionsSegmentWidthsByContent = true
        
        self.maxWidth = frame.width
        self.indicatorHeight = barHeight
        setupIndicator(color: barColor)
        
        addTarget(self, action: #selector(TabBarControl.changedValue), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems(_ items: [String]) {
        for item in items {
            let index = numberOfSegments
            insertSegment(withTitle: item, at: index, animated: false)
        }
        // Hacky
        var segments: [UIView] = subviews.sorted { $0.frame.origin.x < $1.frame.origin.x}
        segments = segments.filter { $0 != indicator }
        layoutIfNeeded()
        widths = []
        for i in 0..<min(segments.count, numberOfSegments) {
            widths.append(segments[i].frame.size.width)
            setWidth(maxWidth / CGFloat(segments.count), forSegmentAt: i)
        }
        layoutIfNeeded()
        updateIndicator()
    }
    
    func setupIndicator(color: UIColor) {
        indicator = UIView()
        indicator.backgroundColor = color
        indicator.frame.size.height = indicatorHeight
        indicator.layer.cornerRadius = indicatorHeight / 2
        addSubview(indicator)
    }
    
    open func updateIndicator() {
        // TODO: Don't hardcode
        self.indicator.frame.origin.y = 1/2 * frame.height + 3
        if !(0..<widths.count ~= index) { return }
        let curWidth = widths[index]
        let newIndex = max(min(widths.count - 1, index + (progress > 0 ? 1 : -1)), 0)
        let newWidth = widths[newIndex]
        let width = curWidth + (newWidth - curWidth) * CGFloat(abs(progress))
        let delta = max(abs(selectedSegmentIndex - index), 1)
        let step = self.frame.width / CGFloat(self.numberOfSegments)
        UIView.animate(withDuration: 0.1) {
            self.indicator.frame.size.width = width
            self.indicator.frame.origin.x = step * CGFloat(Double(self.index) + 0.5 + Double(delta) * self.progress) - width / 2
        }
    }
    
    // MARK: - Delegate Callback
    
    @objc func changedValue() {
        updateIndicator()
        delegate?.tabBarControl(self, didChangeValue: selectedSegmentIndex)
    }
    
}
