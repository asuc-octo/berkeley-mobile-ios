//
//  StudyPactOnboardingViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 10/17/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit


class StudyPactOnboardingViewController: UIViewController {
    
    let signUpLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(40)
        return label
    }()
    
    let bearImage = UIImageView()
    
    let numberImage: UIImageView = {
        let numberImage = UIImageView()
        numberImage.contentMode = .scaleAspectFit
        return numberImage
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Font.regular(24)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textAlignment = .center
        return descriptionLabel
    }()
    
    
    init(_signUpLabelText: String, _bearImage: UIImage, _numberImage: UIImage, _descriptionText: String) {
        signUpLabel.text = _signUpLabelText
        bearImage.image = _bearImage
        numberImage.image = _numberImage
        descriptionLabel.text = _descriptionText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCard()
    }
    
    func setupCard(){
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
//        stack.spacing = 5
        view.addSubview(stack)
        
        let numberTitleStack = UIStackView()
        numberTitleStack.axis = .horizontal
        numberTitleStack.distribution = .equalCentering
        numberTitleStack.alignment = .center
        numberTitleStack.spacing = 14
        numberTitleStack.addArrangedSubview(numberImage)
        numberTitleStack.addArrangedSubview(signUpLabel)
        
        stack.addArrangedSubview(bearImage)
        stack.addArrangedSubview(numberTitleStack)
        stack.addArrangedSubview(descriptionLabel)
        
        bearImage.contentMode = .scaleAspectFit
        bearImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        bearImage.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        numberTitleStack.translatesAutoresizingMaskIntoConstraints = false
        
        bearImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 320/896).isActive = true
        bearImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 310/414).isActive = true
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        stack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 450/896).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 88).isActive = true
    }

}
