//
//  ProfileViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/19/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    private var loggedIn = false
    
    private var profileLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        setupProfile()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: - Update profile info here
        view.endEditing(true)
        return false
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
        
        // Blob
        let blob = UIImage(named: "BlobTopRight")!
        let aspectRatio = blob.size.width / blob.size.height
        let blobView = UIImageView(image: blob)
        blobView.contentMode = .scaleAspectFit

        view.addSubview(blobView)
        blobView.translatesAutoresizingMaskIntoConstraints = false
        blobView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / 1.3).isActive = true
        blobView.heightAnchor.constraint(equalTo: blobView.widthAnchor, multiplier: 1 / aspectRatio).isActive = true
        blobView.topAnchor.constraint(equalTo: view.topAnchor, constant: -blobView.frame.height / 3.5).isActive = true
        blobView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 40).isActive = true
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
        lvstack.distribution = .equalSpacing
        lvstack.alignment = .center
        lvstack.spacing = 19
        
        let rvstack = UIStackView()
        rvstack.axis = .vertical
        rvstack.distribution = .equalSpacing
        rvstack.alignment = .center
        rvstack.spacing = 19
        
        hstack.addArrangedSubview(lvstack)
        hstack.addArrangedSubview(rvstack)
        
        lvstack.setWidthConstraint(100)
        
        // TODO: - Dynamic field data
        let firstnameLabel = UILabel()
        firstnameLabel.text = "First Name"
        firstnameLabel.font = Font.medium(14)
        firstnameLabel.textAlignment = .left
        firstnameLabel.textColor = Color.blackText
        firstnameLabel.numberOfLines = 1
        firstnameLabel.adjustsFontSizeToFitWidth = true
        firstnameLabel.minimumScaleFactor = 0.7
        
        let lastnameLabel = UILabel()
        lastnameLabel.text = "Last Name"
        lastnameLabel.font = Font.medium(14)
        lastnameLabel.textAlignment = .left
        lastnameLabel.textColor = Color.blackText
        lastnameLabel.numberOfLines = 1
        lastnameLabel.adjustsFontSizeToFitWidth = true
        lastnameLabel.minimumScaleFactor = 0.7
        
        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.font = Font.medium(14)
        emailLabel.textAlignment = .left
        emailLabel.textColor = Color.blackText
        emailLabel.numberOfLines = 1
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.7
        
        let phoneLabel = UILabel()
        phoneLabel.text = "Phone Number"
        phoneLabel.font = Font.medium(14)
        phoneLabel.textAlignment = .left
        phoneLabel.textColor = Color.blackText
        phoneLabel.numberOfLines = 1
        phoneLabel.adjustsFontSizeToFitWidth = true
        phoneLabel.minimumScaleFactor = 0.7
        
        let firstnameField = BorderedTextField(text: "Oski")
        let lastnameField = BorderedTextField(text: "Bear")
        let emailField = BorderedTextField(text: "oskibear@berkeley.edu")
        let phoneField = BorderedTextField()
        
        firstnameField.delegate = self
        lastnameField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        
        lvstack.addArrangedSubview(firstnameLabel)
        lvstack.addArrangedSubview(lastnameLabel)
        lvstack.addArrangedSubview(emailLabel)
        lvstack.addArrangedSubview(phoneLabel)

        rvstack.addArrangedSubview(firstnameField)
        rvstack.addArrangedSubview(lastnameField)
        rvstack.addArrangedSubview(emailField)
        rvstack.addArrangedSubview(phoneField)
        
        firstnameField.leftAnchor.constraint(equalTo: firstnameLabel.rightAnchor, constant: 8).isActive = true
        lastnameField.leftAnchor.constraint(equalTo: lastnameLabel.rightAnchor, constant: 8).isActive = true
        emailField.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 8).isActive = true
        phoneField.leftAnchor.constraint(equalTo: phoneLabel.rightAnchor, constant: 8).isActive = true
        
        firstnameField.rightAnchor.constraint(equalTo: rvstack.rightAnchor).isActive = true
        
        firstnameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstnameLabel.setHeightConstraint(36)
        firstnameLabel.leftAnchor.constraint(equalTo: lvstack.leftAnchor).isActive = true
        
        firstnameField.translatesAutoresizingMaskIntoConstraints = false
        firstnameField.setHeightConstraint(36)
        
        lastnameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastnameLabel.setHeightConstraint(36)
        
        lastnameField.translatesAutoresizingMaskIntoConstraints = false
        lastnameField.setHeightConstraint(36)
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.setHeightConstraint(36)
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.setHeightConstraint(36)
        emailField.isUserInteractionEnabled = false
        emailField.textColor = Color.lightLightGrayText
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.setHeightConstraint(36)
        
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.setHeightConstraint(36)
        
        let facebookButton = ActionButton(title: "Link Facebook Profile", font: Font.bold(14))
        facebookButton.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
        facebookButton.setHeightConstraint(40)
        
        view.addSubview(facebookButton)
        
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButton.topAnchor.constraint(equalTo: hstack.bottomAnchor, constant: 30).isActive = true
        facebookButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 18).isActive = true
        facebookButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -18).isActive = true
        
    }
    
    @objc private func facebookButtonPressed(sender: UIButton) {
        // TODO: - Implement this feature
        print("Link facebook pressed")
    }
}
