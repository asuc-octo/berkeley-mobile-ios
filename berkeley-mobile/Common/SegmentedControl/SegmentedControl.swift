//
//  SegmentedControl.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/25/19.
//  Copyright © 2019 ASUC-OCTO. All rights reserved.
//

import UIKit

// MARK: - Delegate

/// Methods for listening for updates in the value of a `SegmentedControl`.
protocol SegmentedControlDelegate: AnyObject {

    /// Called when `segmentedControl` changes its selection to the item in index `value`.
    func segmentedControl(_ segmentedControl: SegmentedControl, didChangeValue value: Int)
}

// MARK: - SegmentedControl

/// A custom `UISegmentedControl` subclass with a selection indicator that animates when the selection is changed.
class SegmentedControl: UISegmentedControl {

    /// The `SegmentedControlDelegate` to notify on value change.
    open weak var delegate: SegmentedControlDelegate?

    // Selection Indicator
    private var indicator: UIView!
    private var indicatorHeight: CGFloat!
    open var indicatorFrame: CGRect { indicator.frame }

    // Selection Label Widths
    private var maxWidth: CGFloat!
    private var widths: [CGFloat]!

    private var items: [String] = []

    /// This value is `true` if the control should be split into equal segments,
    /// otherwise the segment widths depend on the length of the label.
    open var sizeEqually: Bool = true {
        didSet { setItems(items) }
    }

    /// The additional spacing between items when `sizeEqually` is `true`.
    open var spacing: CGFloat = 10 {
        didSet { setItems(items) }
    }
    
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

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // This allows the control to be used smoothly within a scroll view
        return true
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
            NSAttributedString.Key.foregroundColor: BMColor.secondaryText
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: BMColor.primaryText
        ], for: .selected)
        
        self.apportionsSegmentWidthsByContent = true
        
        self.maxWidth = frame.width
        self.indicatorHeight = barHeight
        setupIndicator(color: barColor)
        
        addTarget(self, action: #selector(SegmentedControl.changedValue), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems(_ items: [String]) {
        self.items = items
        removeAllSegments()
        for item in items {
            let index = numberOfSegments
            insertSegment(withTitle: item, at: index, animated: false)
        }
        // Hacky
        var segments: [UIView] = subviews.sorted { $0.frame.origin.x < $1.frame.origin.x}
        segments = segments.filter { $0 != indicator }
        layoutIfNeeded()
        widths = []
        setLabelsAdjustFont(view: self)
        for i in 0..<min(segments.count, numberOfSegments) {
            let intrinsicWidth = segments[i].frame.size.width
            widths.append(sizeEqually ? min(intrinsicWidth, maxWidth / CGFloat(segments.count)) : intrinsicWidth)
            setWidth(sizeEqually ? maxWidth / CGFloat(segments.count) : intrinsicWidth + spacing, forSegmentAt: i)
        }
        selectedSegmentIndex = numberOfSegments > 0 ? 0 : -1
        layoutIfNeeded()
        updateIndicator()
    }
    
    func setLabelsAdjustFont(view: UIView)  {
        let subviews = view.subviews
        for subview in subviews {
            if let label = subview as? UILabel {
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.6
            } else {
                setLabelsAdjustFont(view: subview)
            }
        }
    }
    
    func setupIndicator(color: UIColor) {
        indicator = UIView()
        indicator.backgroundColor = color
        indicator.frame.size.height = indicatorHeight
        indicator.layer.cornerRadius = indicatorHeight / 2
        addSubview(indicator)
    }
    
    open func updateIndicator() {
        sendSubviewToBack(indicator)
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
            let deltaProgress = CGFloat(Double(delta) * self.progress)
            let indexFloat = CGFloat(self.index)
            self.indicator.frame.size.width = width
            self.indicator.frame.origin.x = self.sizeEqually ?
                step * (indexFloat + 0.5 + deltaProgress) - width / 2 :
                self.widths[0..<self.index].reduce(0.0, +) + self.spacing * (indexFloat + 0.5) +
                    deltaProgress * (self.spacing + (self.progress > 0 ? curWidth : newWidth))
        }
    }
    
    // MARK: - Delegate Callback
    
    @objc func changedValue() {
        updateIndicator()
        delegate?.segmentedControl(self, didChangeValue: selectedSegmentIndex)
    }
    
}
