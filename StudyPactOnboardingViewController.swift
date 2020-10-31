//
//  StudyPactOnboardingViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 10/17/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit


class StudyPactOnboardingViewController: UIViewController {

    let pageNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let signUpLabel = UILabel()
        let bearImage = UIImageView()
        let numberImage = UIImageView()
        let descriptionText = UILabel()
        self.view.addSubview(signUpLabel)
        self.view.addSubview(bearImage)
        self.view.addSubview(numberImage)
        self.view.addSubview(descriptionText)
        
        
        
        bearImage.image = UIImage(named: "Onboarding1")
        bearImage.frame = CGRect(x: 0, y: 0, width: 309, height: 321)
        bearImage.translatesAutoresizingMaskIntoConstraints = false
        bearImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bearImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        
        
        signUpLabel.text = "Sign Up"
        signUpLabel.font = UIFont(name: "Raleway-Bold", size: 40)
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20).isActive = true
        signUpLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 65).isActive = true
        
        numberImage.image = UIImage(named: "Onboarding1Num")
        numberImage.frame = CGRect(x: 0, y: 0, width: 34, height: 29)
        numberImage.translatesAutoresizingMaskIntoConstraints = false
        numberImage.rightAnchor.constraint(equalTo: signUpLabel.leftAnchor, constant: -20).isActive = true
        numberImage.centerYAnchor.constraint(equalTo: signUpLabel.centerYAnchor).isActive = true
        
        descriptionText.text = "Complete your profile in less than 5 minutes to get the best pairing"
        descriptionText.font = UIFont(name: "Raleway-Regular", size: 18)
        descriptionText.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        descriptionText.numberOfLines = 0
        descriptionText.textColor = .gray
        descriptionText.textAlignment = .center
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        descriptionText.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 30).isActive = true
        descriptionText.widthAnchor.constraint(equalToConstant: 300).isActive = true

        
    }

}

class StudyPactOnboarding2ViewController: UIViewController {

    let pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let signUpLabel = UILabel()
        let bearImage = UIImageView()
        let numberImage = UIImageView()
        let descriptionText = UILabel()
        self.view.addSubview(signUpLabel)
        self.view.addSubview(bearImage)
        self.view.addSubview(numberImage)
        self.view.addSubview(descriptionText)
        
        
        bearImage.image = UIImage(named: "Onboarding2")
        bearImage.frame = CGRect(x: 0, y: 0, width: 309, height: 321)
        bearImage.translatesAutoresizingMaskIntoConstraints = false
        bearImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bearImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -130).isActive = true
        
        
        signUpLabel.text = "Get Matched"
        signUpLabel.font = UIFont(name: "Raleway-Bold", size: 40)
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20).isActive = true
        signUpLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 65).isActive = true
        
        numberImage.image = UIImage(named: "Onboarding2Num")
        numberImage.frame = CGRect(x: 0, y: 0, width: 34, height: 29)
        numberImage.translatesAutoresizingMaskIntoConstraints = false
        numberImage.rightAnchor.constraint(equalTo: signUpLabel.leftAnchor, constant: -20).isActive = true
        numberImage.centerYAnchor.constraint(equalTo: signUpLabel.centerYAnchor).isActive = true
        
        descriptionText.text = "Upon profile completion, we will find you a list of matches"
        descriptionText.font = UIFont(name: "Raleway-Regular", size: 18)
        descriptionText.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        descriptionText.numberOfLines = 0
        descriptionText.textColor = .gray
        descriptionText.textAlignment = .center
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        descriptionText.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 30).isActive = true
        descriptionText.widthAnchor.constraint(equalToConstant: 300).isActive = true

        
    }

}

class StudyPactOnboarding3ViewController: UIViewController {

    let pageNumber = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let signUpLabel = UILabel()
        let bearImage = UIImageView()
        let numberImage = UIImageView()
        let descriptionText = UILabel()
        self.view.addSubview(signUpLabel)
        self.view.addSubview(bearImage)
        self.view.addSubview(numberImage)
        self.view.addSubview(descriptionText)
        
        
        bearImage.image = UIImage(named: "Onboarding3")
        bearImage.frame = CGRect(x: 0, y: 0, width: 309, height: 321)
        bearImage.translatesAutoresizingMaskIntoConstraints = false
        bearImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bearImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        
        
        signUpLabel.text = "Connect"
        signUpLabel.font = UIFont(name: "Raleway-Bold", size: 40)
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20).isActive = true
        signUpLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 65).isActive = true
        
        numberImage.image = UIImage(named: "Onboarding3Num")
        numberImage.frame = CGRect(x: 0, y: 0, width: 34, height: 29)
        numberImage.translatesAutoresizingMaskIntoConstraints = false
        numberImage.rightAnchor.constraint(equalTo: signUpLabel.leftAnchor, constant: -20).isActive = true
        numberImage.centerYAnchor.constraint(equalTo: signUpLabel.centerYAnchor).isActive = true
        
        descriptionText.text = "Get connected through your choice of contact and start studying!"
        descriptionText.font = UIFont(name: "Raleway-Regular", size: 18)
        descriptionText.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        descriptionText.numberOfLines = 0
        descriptionText.textColor = .gray
        descriptionText.textAlignment = .center
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        descriptionText.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 30).isActive = true
        descriptionText.widthAnchor.constraint(equalToConstant: 300).isActive = true

        
    }

}
