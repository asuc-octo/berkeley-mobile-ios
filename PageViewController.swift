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
    private let pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc) ?? 0
    }
    var getStarted = UIButton()
    let skipButton = UIButton()
    
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
        
        let nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.gray, for: .normal)
        nextButton.frame = CGRect(x: 30, y: 100, width: 50, height: 30)
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextClicked(_:)), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.frame = CGRect(x: 30, y: 100, width: 50, height: 30)
        view.addSubview(skipButton)
        skipButton.addTarget(self, action: #selector(self.skipClicked(_:)), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor).isActive = true
        skipButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24).isActive = true
        skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let closeButton = UIButton()
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.gray, for: .normal)
        closeButton.frame = CGRect(x: 30, y: 100, width: 50, height: 30)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        
        getStarted.frame = CGRect(x: 30, y: 100, width: 220, height: 43)
        getStarted.layer.cornerRadius = getStarted.frame.height/2
        view.addSubview(getStarted)
        getStarted.setTitle("Let's get started!", for: .normal)
        getStarted.titleLabel?.font = Font.bold(15)
        getStarted.backgroundColor = Color.getStartedButton
        getStarted.setTitleColor(.white, for: .normal)
        getStarted.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)
        getStarted.translatesAutoresizingMaskIntoConstraints = false
        getStarted.widthAnchor.constraint(equalToConstant: 200).isActive = true
        getStarted.heightAnchor.constraint(equalToConstant: 43).isActive = true
        getStarted.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        getStarted.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30).isActive = true
        getStarted.isHidden = true
        
    }
    
    @objc func close(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @objc func skipClicked(_: UIButton) {
        
        for i in currentIndex...pages.count-1 {
            setViewControllers([pages[i]], direction: .forward, animated: true, completion: nil)
        }
        pageControl.currentPage = pages.count - 1
        buttonOpacityControl()
        
    }
    
    @objc func nextClicked(_: UIButton){
        moveToNextPage()
    }
    
    func moveToNextPage() {
        
        if currentIndex != pages.count - 1 {
            setViewControllers([pages[currentIndex + 1]], direction: .forward, animated: true, completion: nil)
        }
        pageControl.currentPage += 1

        buttonOpacityControl()
        
    }
    
    func buttonOpacityControl() {
        if pageControl.currentPage == self.pages.count - 1 {
            getStarted.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.getStarted.layer.opacity = 1
                self.skipButton.layer.opacity = 0
            }
            
        }
        
        else if pageControl.currentPage != self.pages.count - 1 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.getStarted.layer.opacity = 0
                    self.skipButton.layer.opacity = 1
                }
            }
        }
    }
    
    func configurePageControl() {
        let initialPage = 0
        let page1 = StudyPactOnboardingViewController(_signUpLabelText: "Sign Up", _bearImage: UIImage(named: "Onboarding1")!, _numberImage: UIImage(named: "Onboarding1Num")!, _descriptionText: "Complete your profile in less than 5 minutes to get the best pairing")
        let page2 = StudyPactOnboardingViewController(_signUpLabelText: "Get Matched", _bearImage: UIImage(named: "Onboarding2")!, _numberImage: UIImage(named: "Onboarding2Num")!, _descriptionText: "Upon profile completion, we will find you a list of matches")
        let page3 = StudyPactOnboardingViewController(_signUpLabelText: "Connect", _bearImage: UIImage(named: "Onboarding3")!, _numberImage: UIImage(named: "Onboarding3Num")!, _descriptionText: "Get connected through your choice of contact and start studying!")
        
        // add the individual viewControllers to the pageViewController
        self.pages.append(page1)
        self.pages.append(page2)
        self.pages.append(page3)
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        // pageControl
        self.pageControl.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
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
                
                buttonOpacityControl()
                
            }
        }
    }


}
