//
//  NewStudyPactClassOnboardingViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/23/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class NewStudyPactClassOnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()
    var model: SPData!
    
    private let pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc) ?? 0
    }
    let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = Font.regular(18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.getStartedButton
        button.addTarget(self, action: #selector(nextClicked(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(closeButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.dataSource = self
        self.delegate = self
        self.model = SPData()

        configurePageControl()
        configureButtons()
        
        let blob = UIImage(named: "StudyPactBlob")!
        let blobView = UIImageView(image: blob)
        blobView.contentMode = .scaleAspectFit
        blobView.setContentCompressionResistancePriority(.required, for: .horizontal)
        blobView.setContentHuggingPriority(.required, for: .horizontal)
        view.addSubview(blobView)
        blobView.translatesAutoresizingMaskIntoConstraints = false
        blobView.topAnchor.constraint(equalTo: view.topAnchor, constant: -blobView.frame.height / 3).isActive = true
        blobView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: blobView.frame.width / 2).isActive = true
        blobView.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        view.sendSubviewToBack(blobView)
        
    }
    
    override func viewWillLayoutSubviews() {
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }
    
    override func viewDidLayoutSubviews() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func configureButtons() {
        view.addSubview(nextButton)
        nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 125/414).isActive = true
        nextButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 45/896).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -100).isActive = true
        
        view.addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        
        
    }
    
    @objc func closeButton(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextClicked(_: UIButton){
        moveToNextPage()
    }
    
    func moveToNextPage() {
        if currentIndex != pages.count - 1 {
            setViewControllers([pages[currentIndex + 1]], direction: .forward, animated: true, completion: nil)
        }
        pageControl.currentPage += 1
    }
    
    func configurePageControl() {
        let initialPage = 0
        let page1 = StudyPactSetupViewController(_onboardingLabelText: "How many people do you want to study with?", _view: PeopleCountPicker_SPOnboarding())
        let page2 = StudyPactSetupViewController(_onboardingLabelText: "What class do you want to study for?", _view: ClassSearch_SPOnboardingViewController())
        let page3 = StudyPactSetupViewController(_onboardingLabelText: "Where do you want to study?", _view: WhereToStudy_SPOnboarding())
        
        
        
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
        self.pageControl.pageIndicatorTintColor = Color.onboardingTint
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        self.pageControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.tintColor = Color.pageViewBackgroundTint
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
            
    // set the pageControl.currentPage to the index of the current viewController in pages
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
                
            }
        }
    }
}

