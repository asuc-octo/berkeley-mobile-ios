//
//  TabBarViewController.swift
//  TabBarPoC
//
//  Created by Kevin Hu on 10/24/19.
//  Copyright © 2019 hu. All rights reserved.
//

import UIKit

// MARK: - Page Struct

struct Page {
    var viewController: UIViewController
    var label: String?
}

// MARK: - TabBarViewController

class TabBarViewController: UIViewController {
    
    private var control: TabBarControl!
    private var pageViewController: UIPageViewController!
    
    open var pages: [Page]! {
        didSet {
            control.setItems(pages.map({$0.label ?? ""}))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup controls
        let size = CGSize(width: view.frame.width - view.layoutMargins.left - view.layoutMargins.right, height: 35)
        control = TabBarControl(frame: CGRect(origin: .zero, size: size),
                                barHeight: CGFloat(13),
                                barColor: UIColor(displayP3Red: 250/255.0, green: 212/255.0, blue: 126/255.0, alpha: 1.0))
        control.delegate = self
        
        view.addSubview(control)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
        
        let viewControllersInCards = [LibraryViewController(), DiningViewController(), FitnessViewController()]
        
        pages = [
            Page(viewController: viewControllersInCards[0], label: "Libraries"),
            Page(viewController: viewControllersInCards[1], label: "Dining"),
            Page(viewController: viewControllersInCards[2], label: "Fitness")
        ]
    }

}

// MARK: - UIPageViewControllerDelegate

extension TabBarViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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

extension TabBarViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        control.progress = Double((scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width)
        animating = control.progress != 0
    }
    
}

// MARK: - TabBarControlDelegate

extension TabBarViewController: TabBarControlDelegate {
    
    func tabBarControl(_ tabBarControl: TabBarControl, didChangeValue value: Int) {
        if !animating {
            pageViewController.setViewControllers([pages[value].viewController],
                                                  direction: value > index ? .forward : .reverse,
                                                  animated: true) { success in self.control.index = value }
        }
    }
    
}
