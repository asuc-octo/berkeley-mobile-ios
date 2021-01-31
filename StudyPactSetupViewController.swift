//
//  StudyPactSetupViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/28/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class StudyPactSetupViewController: UIViewController {

    var onboardingLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textAlignment = .center
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var onboardingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(_onboardingLabelText: String, _view: UIView) {
        onboardingLabel.text = _onboardingLabelText
        onboardingView = _view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupToHideKeyboardOnTapOnView()
        
    }
    
    func setupView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 35
        view.addSubview(stack)
        
        stack.addArrangedSubview(onboardingLabel)
        stack.addArrangedSubview(onboardingView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        

        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/414).isActive = true
        onboardingView.topAnchor.constraint(equalTo: onboardingLabel.bottomAnchor, constant: 35).isActive = true
        onboardingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 180/896).isActive = true
        onboardingView.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        
    }
    
    

    

}
