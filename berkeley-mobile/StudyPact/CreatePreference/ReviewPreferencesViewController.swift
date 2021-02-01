//
//  ReviewPreferencesViewController.swift
//  berkeley-mobile
//
//  Created by Shawn Huang on 1/31/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ReviewPreferencesViewController: UIViewController {
    let preferenceVC: CreatePreferenceViewController
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(36)
        label.text = "Let's Review!"
        label.textAlignment = .center
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let lookingLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium(18)
        label.text = "You are looking for a:"
        label.textAlignment = .center
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let preferenceLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textAlignment = .center
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override func viewDidLoad() {
        setUpLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabels()
    }
    
    init(preferenceVC: CreatePreferenceViewController) {
        self.preferenceVC = preferenceVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpLabels() {
        self.view.addSubview(reviewLabel)
        reviewLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        reviewLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: view.frame.height * 0.2).isActive = true
        
        self.view.addSubview(lookingLabel)
        lookingLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lookingLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 50).isActive = true
        
        self.view.addSubview(preferenceLabel)
        preferenceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        preferenceLabel.topAnchor.constraint(equalTo: lookingLabel.bottomAnchor, constant: 20).isActive = true
        preferenceLabel.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor, constant: 16).isActive = true
        preferenceLabel.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: 16).isActive = true
    }
    
    private func updateLabels() {
        guard let preferenceClass = preferenceVC.preference.className,
              let preferenceNumber = preferenceVC.preference.numberOfPeople,
              let preferenceVirtual = preferenceVC.preference.isVirtual else {
            preferenceLabel.text = "There was an error with your selection."
            lookingLabel.isHidden = true
            reviewLabel.isHidden = true
            return
        }
        lookingLabel.isHidden = false
        reviewLabel.isHidden = false
        preferenceLabel.text = "\(preferenceClass) study group\nwith \(preferenceNumber) people\nmeeting \(preferenceVirtual ? "virtually" : "in person")"
    }
}
