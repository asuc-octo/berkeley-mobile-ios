//
//  SegmentedControlViewController.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 10/24/19.
//  Copyright © 2019 ASUC-OCTO. All rights reserved.
//

import UIKit

// MARK: - Page Struct

/// A structure describing a single page that is navigatable to from a `SegmentedControlViewController`.
struct Page {

    /// The view controller to be presented for this page.
    var viewController: UIViewController

    /// The string to be displayed in the `SegmentedControl` button for this page.
    var label: String
}

// MARK: - SegmentedControlViewController

fileprivate let kControlHeight: CGFloat = 35
fileprivate let kBarHeight: CGFloat = 13
fileprivate let kViewMargin: CGFloat = 15

/// A view controller containing a `UIPageViewController` synced-up with a `SegmentedControl`.
class SegmentedControlViewController: UIViewController {

    /// The `SegmentedControl` displayed at the top of this view controller.
    var control: SegmentedControl!

    /// Container for additional views displayed between `control` and `pageViewController`.
    var header: UIStackView!

    /// The `UIScrollView` containing `control` that allows it to scroll horizontally if there are many options.
    private var scrollView: UIScrollView!

    /// An arrow that displays to the right of `control` when the rightmost edge of `scrollView` is not visible.
    private var indicator: UIButton!

    /// The `UIPageViewController` controlled by `control`.
    private var pageViewController: UIPageViewController!

    /// The list of `Page` structs that determine the contents of `control` and `pageViewController`.
    open var pages: [Page]! {
        didSet {
            control.setItems(pages.map { $0.label })
            index = 0
        }
    }
    open var index: Int {
        get {
            guard let vc = pageViewController.viewControllers?.first else {
                return -1
            }
            return pages.firstIndex(where: { $0.viewController == vc }) ?? -1
        }
        set(newIndex) {
            if 0..<pages.count ~= newIndex {
                control.index = newIndex
                pageViewController.setViewControllers([pages[newIndex].viewController], direction: .forward, animated: true)
            }
        }
    }
    private var animating: Bool = false {
        didSet {
            control.isEnabled = !animating
        }
    }

    /**
      Initializes the view controller with the given options.
      - Parameter pages: A list of pages that will be shown through this view controller.
      - Parameter controlInsets: Contains the left and right edge insets that will be used to set the width and position of
            the `SegmentedControl`. If this value is `nil`, the control will extend to the edges of the view controller.
      - Parameter centerControl: Horizontally centers `control` if this value is `true`, otherwise left-align `control`
            with the left inset provided by `controlInsets`.
      - Parameter scrollable: If there are many pages, allows the control to scroll horizontally instead of
            shrinking or truncating the control labels.
    */
    init(pages: [Page], controlInsets: UIEdgeInsets? = nil, centerControl: Bool = true, scrollable: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        // Setup UIScrollView
        let insets = controlInsets ?? view.layoutMargins
        let size = CGSize(width: view.frame.width - insets.left - insets.right, height: kControlHeight)
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        if centerControl {
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        } else {
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left).isActive = true
        }

        // Setup Indicator
        indicator = UIButton()
        let image = UIImage(named: "Back")?.colored(Color.blackText)!.withRenderingMode(.alwaysTemplate)
        indicator.addTarget(self, action: #selector(didTapIndicator), for: .touchUpInside)
        indicator.setImage(image, for: .normal)
        indicator.tintColor = Color.secondaryText
        indicator.transform = CGAffineTransform(scaleX: -1, y: 1)
        indicator.backgroundColor = Color.modalBackground
        indicator.layer.cornerRadius = size.height / 2
        indicator.layer.shadowRadius = 5
        indicator.layer.shadowOpacity = 0.25
        indicator.layer.shadowOffset = .zero
        indicator.layer.shadowColor = UIColor.black.cgColor
        indicator.layer.shadowPath = UIBezierPath(rect: indicator.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath

        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        indicator.leftAnchor.constraint(equalTo: scrollView.rightAnchor, constant: kViewMargin).isActive = true
        indicator.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        indicator.widthAnchor.constraint(equalTo: indicator.heightAnchor).isActive = true

        // Setup controls
        let nonzeroSize = CGSize(width: 1, height: kControlHeight)
        control = SegmentedControl(frame: CGRect(origin: .zero, size: scrollable ? nonzeroSize : size),
                                barHeight: kBarHeight,
                                barColor: Color.segmentedControlHighlight)
        control.delegate = self
        scrollView.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setConstraintsToView(top: scrollView, bottom: scrollView, left: scrollView, right: scrollView)

        // Setup header
        header = UIStackView()
        header.axis = .vertical
        /* Add a dummy view with intrinsic height to
           give the stackview an intrinsic height. */
        header.addArrangedSubview(UILabel())
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        // Setup UIPageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        add(child: pageViewController, frame: view.frame)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let scrollViews = pageViewController.view.subviews.filter { $0 is UIScrollView }
        if let scrollView = scrollViews.first as? UIScrollView {
            scrollView.delegate = self
        }

        defer { self.pages = pages }
    }

    convenience init() {
        self.init(pages: [])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Indicator

extension SegmentedControlViewController {

    @objc func didTapIndicator() {
        if index < 0 { return }
        let nextIndex = min(pages.count - 1, index + 1)
        guard nextIndex != index, !animating else { return }
        pageViewController.setViewControllers([pages[nextIndex].viewController],
                                              direction: .forward,
                                              animated: true) { success in self.control.index = nextIndex }
    }

    func updateIndicator() {
        let atEnd = (scrollView.contentOffset.x + scrollView.frame.size.width) / scrollView.contentSize.width >= 1.0
        let onLastPage = index == pages.count - 1
        UIView.animate(withDuration: 0.2) {
            self.indicator.alpha = atEnd || onLastPage ? 0.0 : 1.0
        }
    }

}

// MARK: - UIPageViewControllerDelegate

extension SegmentedControlViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        control.index = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if index < 0 { return nil }
        let nextIndex = max(0, index - 1)
        return nextIndex == index ? nil : pages[nextIndex].viewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if index < 0 { return nil }
        let nextIndex = min(pages.count - 1, index + 1)
        return nextIndex == index ? nil : pages[nextIndex].viewController
    }
    
}

// MARK: - UIScrollViewDelegate

extension SegmentedControlViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.scrollView {
            control.progress = Double((scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width)
            animating = control.progress != 0
            self.scrollView.scrollRectToVisible(control.indicatorFrame, animated: true)
        }
        updateIndicator()
    }
    
}

// MARK: - SegmentedControlDelegate

extension SegmentedControlViewController: SegmentedControlDelegate {
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didChangeValue value: Int) {
        if !animating {
            pageViewController.setViewControllers([pages[value].viewController],
                                                  direction: value > index ? .forward : .reverse,
                                                  animated: true) { success in self.control.index = value }
        }
    }
    
}
