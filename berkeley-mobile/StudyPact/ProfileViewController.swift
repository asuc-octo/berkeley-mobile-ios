//
//  ProfileViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/19/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private var loggedIn = false
    
    private var profileLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        setupProfile()
    }
    
}

extension ProfileViewController {
    func setupHeader() {
        profileLabel = UILabel()
        profileLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        profileLabel.numberOfLines = 0
        profileLabel.font = Font.bold(30)
        profileLabel.text = "Profile"
        view.addSubview(profileLabel)
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        profileLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
    }
    
    func setupProfile() {
        let initials = UILabel()
        initials.text = "OB"
        initials.textAlignment = .center
        initials.font = Font.bold(40)
        initials.layer.cornerRadius = 50
        initials.layer.masksToBounds = true
        initials.backgroundColor = Color.lightGrayText
        initials.textColor = UIColor.white
        
        view.addSubview(initials)
        
        initials.translatesAutoresizingMaskIntoConstraints = false
        initials.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 15).isActive = true
        initials.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        initials.setHeightConstraint(100)
        initials.setWidthConstraint(100)
                
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.distribution = .equalCentering
        hstack.alignment = .center
        
        view.addSubview(hstack)
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.topAnchor.constraint(equalTo: initials.bottomAnchor, constant: 15).isActive = true
        hstack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 15).isActive = true
        hstack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -15).isActive = true
        
        let lvstack = UIStackView()
        lvstack.axis = .vertical
        lvstack.distribution = .fillEqually
        lvstack.alignment = .center
        
        let rvstack = UIStackView()
        lvstack.axis = .vertical
        rvstack.distribution = .fillEqually
        rvstack.alignment = .center
        
        hstack.addArrangedSubview(lvstack)
        hstack.addArrangedSubview(rvstack)
        
        // TODO: - Dynamic field data
        let firstnameLabel = UILabel()
        firstnameLabel.text = "First Name"
        firstnameLabel.font = Font.medium(12)
        firstnameLabel.textAlignment = .left
        firstnameLabel.textColor = Color.blackText
        firstnameLabel.numberOfLines = 1
        firstnameLabel.adjustsFontSizeToFitWidth = true
        firstnameLabel.minimumScaleFactor = 0.7
        
        let firstnameField = BorderedTextField(text: "OB")
        
        
        lvstack.addArrangedSubview(firstnameLabel)
        rvstack.addArrangedSubview(firstnameField)
        
        firstnameField.leftAnchor.constraint(equalTo: firstnameLabel.rightAnchor).isActive = true
        
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstnameLabel.setHeightConstraint(36)
        firstnameLabel.setWidthConstraint(100)
        
        firstnameField.translatesAutoresizingMaskIntoConstraints = false
        firstnameField.setHeightConstraint(36)
    }
}
