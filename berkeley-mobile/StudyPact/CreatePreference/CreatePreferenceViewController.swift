//
//  CreatePreferenceViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/23/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class CreatePreferenceViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()
    var preference: StudyPactPreference = StudyPactPreference()
    var currentDelegate: EnableNextDelegate? {
        didSet {
            setNextEnabled()
        }
    }
    
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
        button.backgroundColor = Color.StudyPact.CreatePreference.enabledNextButton
        button.addTarget(self, action: #selector(nextClicked(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save Preference", for: .normal)
        button.titleLabel?.font = Font.regular(18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.StudyPact.CreatePreference.selectedPink
        button.addTarget(self, action: #selector(savePreference(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
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
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
    }
    
    override func viewDidLayoutSubviews() {
        pageControl.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func configureButtons() {
        view.addSubview(nextButton)
        nextButton.widthAnchor.constraint(equalToConstant: 143).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 41).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: view.frame.height * -0.1).isActive = true
        
        view.addSubview(saveButton)
        saveButton.widthAnchor.constraint(equalToConstant: 195).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 41).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor).isActive = true
        
        view.addSubview(closeButton)
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    }
    
    @objc func closeButton(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextClicked(_: UIButton){
        moveToNextPage()
    }
    
    @objc func savePreference(_: UIButton) {
        // TODO: AddClass api call
        print("send preference to backend")
        print(preference)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setNextEnabled() {
        guard let currentDelegate = self.currentDelegate else { return }
        if currentDelegate.isNextEnabled {
            self.dataSource = self
            nextButton.isEnabled = true
            nextButton.backgroundColor = Color.StudyPact.CreatePreference.enabledNextButton
        } else {
            self.dataSource = nil
            nextButton.isEnabled = false
            nextButton.backgroundColor = Color.StudyPact.CreatePreference.disabledNextbutton
        }
    }
    
    func moveToNextPage() {
        if currentIndex != pages.count - 1 {
            setViewControllers([pages[currentIndex + 1]], direction: .forward, animated: true, completion: { _ in
                self.updateButtons(vc: self.pages[self.pageControl.currentPage])
            })
        }
        pageControl.currentPage += 1
    }
    
    func configurePageControl() {
        let initialPage = 0
        let page1 = CreatePreferenceFrameViewController(labelText: "How many people do you want to study with?", containedView: SelectPeopleView(preferenceVC: self))
        let page2 = CreatePreferenceFrameViewController(labelText: "What class do you want to study for?", containedView: SelectClassView(preferenceVC: self))
        let page3 = CreatePreferenceFrameViewController(labelText: "Where do you want to study?", containedView: SelectLocationView(preferenceVC: self))
        let page4 = ReviewPreferencesViewController(preferenceVC: self)
        currentDelegate = page1.containedView as? EnableNextDelegate
        
        // add the individual viewControllers to the pageViewController
        self.pages.append(page1)
        self.pages.append(page2)
        self.pages.append(page3)
        self.pages.append(page4)
        
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        // pageControl
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.currentPage = initialPage
        self.pageControl.pageIndicatorTintColor = Color.StudyPact.Onboarding.onboardingTint
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        self.pageControl.widthAnchor.constraint(equalToConstant: 140).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.pageControl.tintColor = Color.StudyPact.Onboarding.pageViewBackgroundTint
        self.pageControl.isUserInteractionEnabled = false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController), viewControllerIndex != 0 else { return nil }
        
        return self.pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.pages.firstIndex(of: viewController), viewControllerIndex < self.pages.count - 1 else { return nil }
        return self.pages[viewControllerIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // set the pageControl.currentPage to the index of the current viewController in pages
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
            }
        }
        self.updateButtons(vc: pageViewController.viewControllers?[0])
    }
    
    private func updateButtons(vc: UIViewController?) {
        DispatchQueue.main.async {
            if vc as? ReviewPreferencesViewController != nil {
                self.nextButton.isHidden = true
                self.saveButton.isHidden = false
            } else {
                self.nextButton.isHidden = false
                self.saveButton.isHidden = true
            }
            if let frame = vc as? CreatePreferenceFrameViewController,
               let vc = frame.containedView as? EnableNextDelegate {
                self.currentDelegate = vc
            }
        }
    }
}

protocol EnableNextDelegate {
    var isNextEnabled: Bool { get set }
}
