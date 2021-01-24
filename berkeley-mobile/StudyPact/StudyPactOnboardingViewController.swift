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
        label.font = Font.bold(36)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bearImage = UIImageView()
    
    let numberImage: UIImageView = {
        let numberImage = UIImageView()
        numberImage.contentMode = .scaleAspectFit
        numberImage.translatesAutoresizingMaskIntoConstraints = false
        return numberImage
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Font.regular(18)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
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
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 30
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
        signUpLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height * 0.05).isActive = true
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        bearImage.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
    }

}
