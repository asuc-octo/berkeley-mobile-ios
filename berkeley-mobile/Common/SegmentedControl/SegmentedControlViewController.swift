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

/// A view controller containing a `UIPageViewController` synced-up with a `SegmentedControl`.
class SegmentedControlViewController: UIViewController {

    /// The `SegmentedControl` displayed at the top of this view controller.
    var control: SegmentedControl!

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
    */
    init(pages: [Page], controlInsets: UIEdgeInsets? = nil, centerControl: Bool = true) {
        super.init(nibName: nil, bundle: nil)

        // Setup controls
        let insets = controlInsets ?? view.layoutMargins
        let size = CGSize(width: view.frame.width - insets.left - insets.right, height: 35)
        control = SegmentedControl(frame: CGRect(origin: .zero, size: size),
                                barHeight: CGFloat(13),
                                barColor: UIColor(displayP3Red: 250/255.0, green: 212/255.0, blue: 126/255.0, alpha: 1.0))
        control.delegate = self

        view.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        if centerControl {
            control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        } else {
            control.leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left).isActive = true
        }
        control.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

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
        pageViewController.view.topAnchor.constraint(equalTo: control.bottomAnchor).isActive = true
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
        control.progress = Double((scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width)
        animating = control.progress != 0
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
