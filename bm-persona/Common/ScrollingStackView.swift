//
//  ScrollingStackView.swift
//  bm-persona
//
//  Created by Kevin Hu on 9/5/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

/// A view containing a vertical `UIStackView` in a `UIScrollView` with a dynamic content height to match the contents of the stack.
class ScrollingStackView: UIView {

    /// The `UIScrollView` containing `stackView.
    open var scrollView: UIScrollView!

    /// The `UIStackView` containing the contents of this view.
    open var stackView: UIStackView!

    /// The vertical offset applied to the contents of `scrollView` relative to this view's parent.
    open var yOffset: CGFloat {
        return frame.minY + scrollView.contentInset.top
    }

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        setupScrollView()
        setupStackView()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Views

    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        scrollView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.rightAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.widthAnchor).isActive = true
    }

}
