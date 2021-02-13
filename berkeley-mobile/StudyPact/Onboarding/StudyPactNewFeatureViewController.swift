//
//  StudyPactNewFeatureViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 2/12/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class StudyPactNewFeatureViewController: UIViewController {
    let featureLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(40)
        label.text = "New Feature!"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bearImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "OnboardingBear")
        return imageView
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Font.regular(18)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "StudyPact - finding students to study with has never been easier."
        return descriptionLabel
    }()
    
    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let getStartedButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.medium(15)
        button.setTitle("Get Started!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.StudyPact.Onboarding.getStartedBlue
        button.addTarget(self, action: #selector(getStarted(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 130).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    let laterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.medium(15)
        button.setTitle("Sign Up Later.", for: .normal)
        button.setTitleColor(Color.StudyPact.Onboarding.getStartedBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 2
        button.layer.borderColor = Color.StudyPact.Onboarding.getStartedBlue.cgColor
        button.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 130).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
        laterButton.layer.cornerRadius = laterButton.frame.height / 2
    }
    
    @objc func getStarted(_: UIButton) {
        weak var pvc = self.presentingViewController

        self.dismiss(animated: false, completion: {
            let vc = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true, completion: nil)
        })
    }
    @objc func dismiss(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        stack.spacing = view.frame.height * 0.03
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        stack.addArrangedSubview(bearImageView)
        stack.addArrangedSubview(featureLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(buttonsView)
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        
        bearImageView.contentMode = .scaleAspectFit
        bearImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        
        buttonsView.addSubview(getStartedButton)
        buttonsView.addSubview(laterButton)
        getStartedButton.leftAnchor.constraint(equalTo: buttonsView.leftAnchor).isActive = true
        getStartedButton.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
        getStartedButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor).isActive = true
        laterButton.leftAnchor.constraint(equalTo: getStartedButton.rightAnchor, constant: 20).isActive = true
        laterButton.rightAnchor.constraint(equalTo: buttonsView.rightAnchor).isActive = true
        laterButton.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
        laterButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor).isActive = true
    }
}
