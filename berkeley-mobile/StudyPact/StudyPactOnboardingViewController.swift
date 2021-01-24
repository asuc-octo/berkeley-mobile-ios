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
    
    let centeringView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let getStarted: UIButton = {
        let button = UIButton()
        button.setTitle("Let's get started!", for: .normal)
        button.titleLabel?.font = Font.bold(15)
        button.backgroundColor = Color.getStartedButton
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(getStarted(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        getStarted.layer.cornerRadius = getStarted.frame.height / 2
    }
    
    @objc func getStarted(_: UIButton) {
        if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
            tabBarController.selectProfileTab()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    var hasGetStarted = false
    
    init(_signUpLabelText: String, _bearImage: UIImage, _numberImage: UIImage, _descriptionText: String, _hasGetStarted: Bool = false) {
        signUpLabel.text = _signUpLabelText
        bearImage.image = _bearImage
        numberImage.image = _numberImage
        descriptionLabel.text = _descriptionText
        self.hasGetStarted = _hasGetStarted
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
        
        if self.hasGetStarted {
            view.addSubview(getStarted)
            view.addSubview(centeringView)
            centeringView.topAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
            centeringView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            getStarted.widthAnchor.constraint(equalToConstant: 200).isActive = true
            getStarted.heightAnchor.constraint(equalToConstant: 43).isActive = true
            getStarted.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            getStarted.centerYAnchor.constraint(equalTo: centeringView.centerYAnchor).isActive = true
        }
    }
    
}
