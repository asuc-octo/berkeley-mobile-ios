//
//  PageViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 10/17/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()
    var pageColors = [UIColor]()
    private let pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc) ?? 0
    }
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.medium(18)
        button.setTitle("X", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func configureButtons() {
        view.addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    }
    
    @objc func close(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func moveToNextPage() {
        if currentIndex != pages.count - 1 {
            setViewControllers([pages[currentIndex + 1]], direction: .forward, animated: true, completion: nil)
        }
        pageControl.currentPage += 1
        pageControl.pageIndicatorTintColor = pageColors[pageControl.currentPage]
    }
    
    func configurePageControl() {
        let initialPage = 0
        pageColors = [Color.StudyPact.Onboarding.pink, Color.StudyPact.Onboarding.yellow, Color.StudyPact.Onboarding.blue]
        let page1 = StudyPactOnboardingViewController(stepText: "Sign Up", themeColor: pageColors[0], stepNumber: 1, screenshotImage: UIImage(named: "OnboardingScreenshot1")!, blobImage: UIImage(named: "OnboardingBlob1")!, descriptionText: "Sign up by tapping the Sign In button on the new study tab of the Berkeley Mobile home screen to authenticate your berkeley.edu Gmail account.", pageViewController: self, boldedStrings: ["Sign In", "study tab"])
        let page2 = StudyPactOnboardingViewController(stepText: "Create a Preference", themeColor: pageColors[1], stepNumber: 2, screenshotImage: UIImage(named: "OnboardingScreenshot2")!, blobImage: UIImage(named: "OnboardingBlob2")!, descriptionText: "Create a study preference by filling out your class details, preferred method of study, and number of members.", pageViewController: self)
        let page3 = StudyPactOnboardingViewController(stepText: "Get Matched!", themeColor: pageColors[2], stepNumber: 3, screenshotImage: UIImage(named: "OnboardingScreenshot3")!, blobImage: UIImage(named: "OnboardingBlob3")!, descriptionText: "Once you create a preference, your group will be marked as pending. Check back frequently to see if you’ve been matched with a group!", pageViewController: self, boldedStrings: ["pending"], getStarted: true)
        
        // add the individual viewControllers to the pageViewController
        self.pages.append(page1)
        self.pages.append(page2)
        self.pages.append(page3)
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        // pageControl
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.currentPage = initialPage
        self.pageControl.pageIndicatorTintColor = pageColors[pageControl.currentPage]
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        self.pageControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.isUserInteractionEnabled = false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController), viewControllerIndex != 0 else { return nil }
        
        return self.pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController), viewControllerIndex < self.pages.count - 1 else { return nil }
                // go to next page in array
        return self.pages[viewControllerIndex + 1]
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                pageControl.currentPage = viewControllerIndex
                pageControl.pageIndicatorTintColor = pageColors[pageControl.currentPage]
            }
        }
    }
}
