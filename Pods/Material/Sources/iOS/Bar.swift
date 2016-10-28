/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

@objc(ContentViewAlignment)
public enum ContentViewAlignment: Int {
    case any
    case center
}

open class Bar: View {
    /// Will layout the view.
    open var willLayout: Bool {
        return 0 < width && 0 < height && nil != superview
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    /// Should center the contentView.
    open var contentViewAlignment = ContentViewAlignment.any {
        didSet {
            layoutSubviews()
        }
    }
    
    /// A preset wrapper around contentEdgeInsets.
    open var contentEdgeInsetsPreset: EdgeInsetsPreset {
        get {
            return grid.contentEdgeInsetsPreset
        }
        set(value) {
            grid.contentEdgeInsetsPreset = value
        }
    }
    
    /// A reference to EdgeInsets.
    @IBInspectable
    open var contentEdgeInsets: EdgeInsets {
        get {
            return grid.contentEdgeInsets
        }
        set(value) {
            grid.contentEdgeInsets = value
        }
    }
    
    /// A preset wrapper around interimSpace.
    open var interimSpacePreset = InterimSpacePreset.none {
        didSet {
            interimSpace = InterimSpacePresetToValue(preset: interimSpacePreset)
        }
    }
    
    /// A wrapper around grid.interimSpace.
    @IBInspectable
    open var interimSpace: InterimSpace {
        get {
            return grid.interimSpace
        }
        set(value) {
            grid.interimSpace = value
        }
    }
    
    /// Grid cell factor.
    @IBInspectable
    open var gridFactor: CGFloat = 12 {
        didSet {
            assert(0 < gridFactor, "[Material Error: gridFactor must be greater than 0.]")
            layoutSubviews()
        }
    }
    
    /// ContentView that holds the any desired subviews.
    open private(set) lazy var contentView = View()
    
    /// Left side UIViews.
    open var leftViews = [UIView]() {
        didSet {
            for v in oldValue {
                v.removeFromSuperview()
            }
            layoutSubviews()
        }
    }
    
    /// Right side UIViews.
    open var rightViews = [UIView]() {
        didSet {
            for v in oldValue {
                v.removeFromSuperview()
            }
            layoutSubviews()
        }
    }
    
    /// Center UIViews.
    open var centerViews: [UIView] {
        get {
            return contentView.grid.views
        }
        set(value) {
            for v in contentView.grid.views {
                v.removeFromSuperview()
            }
            contentView.grid.views = value
        }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     An initializer that initializes the object with a CGRect object.
     If AutoLayout is used, it is better to initilize the instance
     using the init() initializer.
     - Parameter frame: A CGRect instance.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Basic initializer.
    public init() {
        super.init(frame: .zero)
        frame.size = intrinsicContentSize
    }
    
    /**
     A convenience initializer with parameter settings.
     - Parameter leftViews: An Array of UIViews that go on the left side.
     - Parameter rightViews: An Array of UIViews that go on the right side.
     - Parameter centerViews: An Array of UIViews that go in the center.
     */
    public init(leftViews: [UIView]? = nil, rightViews: [UIView]? = nil, centerViews: [UIView]? = nil) {
        super.init(frame: .zero)
        self.leftViews = leftViews ?? []
        self.rightViews = rightViews ?? []
        self.centerViews = centerViews ?? []
        frame.size = intrinsicContentSize
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard willLayout else {
            return
        }
        
        reload()
    }
    
    /// Reloads the view.
    open func reload() {
        var lc = 0
        var rc = 0
        let l = (CGFloat(leftViews.count) * interimSpace)
        let r = (CGFloat(rightViews.count) * interimSpace)
        let p = width - l - r - contentEdgeInsets.left - contentEdgeInsets.right
        let columns = Int(ceil(p / gridFactor))
        
        grid.begin()
        grid.views.removeAll()
        grid.axis.columns = columns
        
        for v in leftViews {
            if let b = v as? UIButton {
                b.contentEdgeInsets = .zero
                b.titleEdgeInsets = .zero
            }
            
            v.width = v.intrinsicContentSize.width
            v.sizeToFit()
            v.grid.columns = Int(ceil(v.width / gridFactor)) + 2
            
            lc += v.grid.columns
            
            grid.views.append(v)
        }
        
        grid.views.append(contentView)
        
        for v in rightViews {
            if let b = v as? UIButton {
                b.contentEdgeInsets = .zero
                b.titleEdgeInsets = .zero
            }
            
            v.width = v.intrinsicContentSize.width
            v.sizeToFit()
            v.grid.columns = Int(ceil(v.width / gridFactor)) + 2
            
            rc += v.grid.columns
            
            grid.views.append(v)
        }
        
        contentView.grid.begin()
        
        if .center == contentViewAlignment {
            if lc < rc {
                contentView.grid.columns = columns - 2 * rc
                contentView.grid.offset.columns = rc - lc
            } else {
                contentView.grid.columns = columns - 2 * lc
                contentView.grid.offset.columns = 0
                rightViews.first?.grid.offset.columns = lc - rc
            }
        } else {
            contentView.grid.columns = columns - lc - rc
        }
        
        grid.commit()
        contentView.grid.commit()
        
        divider.reload()
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepare method
     to initialize property values and other setup operations.
     The super.prepare method should always be called immediately
     when subclassing.
     */
    open override func prepare() {
        super.prepare()
        heightPreset = .normal
        autoresizingMask = .flexibleWidth
        interimSpacePreset = .interimSpace3
        contentEdgeInsetsPreset = .square1
        prepareContentView()
    }
    
    /// Prepares the contentView.
    private func prepareContentView() {
        contentView.backgroundColor = nil
    }
}
