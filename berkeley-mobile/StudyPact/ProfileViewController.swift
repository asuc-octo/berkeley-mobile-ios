//
//  ProfileViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/19/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GIDSignInDelegate {
    
    private var loggedIn = false
    private var loginButton: GIDSignInButton!
    
    private var profileLabel: UILabel!
    private var initialsLabel: ProfileLabel!
    private var profileImageView: UIImageView!
    private var profileImage: UIImage! {
        didSet {
            profileImageView.image = profileImage
            initialsLabel.isHidden = true
            profileImageView.isHidden = false
        }
    }
    private var fullNameField: BorderedTextField!
    private var emailTextField: TaggedTextField!
    
    private var changeImageButton: UIButton!
    private var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
        
        setupHeader()
        
        GIDSignIn.sharedInstance()?.delegate = self
        
        if GIDSignIn.sharedInstance().hasPreviousSignIn() {
            // Signed in

            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            loggedInView()
        } else {
            GIDSignIn.sharedInstance()?.presentingViewController = self
            
            loggedOutView()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else {
            loggedOutView()
            return
        }
        // TODO: - Store the useful hash?
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        loggedInView()
        
        let userId = user.userID  // Client side only
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let email = user.profile.email
        
        initialsLabel.text = String(fullName?.prefix(1) ?? "")
        fullNameField.text = fullName
        emailTextField.textField.text = email
        
        if user.profile.hasImage {
            guard let imageUrl = user.profile.imageURL(withDimension: 250) else { return }
            ImageLoader.shared.getImage(url: imageUrl) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async() { [weak self] in
                        self!.profileImage = image
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        loggedOutView()
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
    func loggedInView() {
        if let _ = loginButton {
            loginButton.isHidden = true
        }
        
        setupProfile()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
//        imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
    }
    
    func loggedOutView() {
        loginButton = GIDSignInButton()
        
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
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
        let initials = ProfileLabel(text: "O")
        
        view.addSubview(initials)
        
        initials.translatesAutoresizingMaskIntoConstraints = false
        initials.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 15).isActive = true
        initials.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        initials.setHeightConstraint(100)
        initials.setWidthConstraint(100)
        
        initialsLabel = initials
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 15).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.setHeightConstraint(100)
        imageView.setWidthConstraint(100)
        
        profileImageView = imageView
        
        let regularAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.font: Font.medium(14),
            NSAttributedString.Key.foregroundColor: Color.lightGrayText
        ]
        
        let pressedAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.font: Font.medium(14),
            NSAttributedString.Key.foregroundColor: Color.lightLightGrayText
        ]
        
        let button = UIButton()
        let attributedString = NSMutableAttributedString(string: "Edit Profile Picture", attributes: regularAttributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        let pressedAttributedString = NSMutableAttributedString(string: "Edit Profile Picture", attributes: pressedAttributes)
        button.setAttributedTitle(pressedAttributedString, for: .selected)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: initials.bottomAnchor, constant: 15).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.setHeightConstraint(18)
        button.addTarget(self, action: #selector(changeImageButtonPressed), for: .touchUpInside)
        
        button.isHidden = true  // remove in future
        changeImageButton = button
        
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.distribution = .equalCentering
        hstack.alignment = .center
        
        view.addSubview(hstack)
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.topAnchor.constraint(equalTo: initialsLabel.bottomAnchor, constant: 30).isActive = true
        hstack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 15).isActive = true
        hstack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -15).isActive = true
        
        let lvstack = UIStackView()
        lvstack.axis = .vertical
        lvstack.distribution = .equalSpacing
        lvstack.alignment = .center
        lvstack.spacing = 17
        
        let rvstack = UIStackView()
        rvstack.axis = .vertical
        rvstack.distribution = .equalSpacing
        rvstack.alignment = .center
        rvstack.spacing = 19
        
        hstack.addArrangedSubview(lvstack)
        hstack.addArrangedSubview(rvstack)
        
        lvstack.setWidthConstraint(100)
        
        // TODO: - Dynamic field data
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = Font.medium(14)
        nameLabel.textAlignment = .left
        nameLabel.textColor = Color.blackText
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
        
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
        
        let facebookLabel = UILabel()
        facebookLabel.text = "Facebook ID"
        facebookLabel.font = Font.medium(14)
        facebookLabel.textAlignment = .left
        facebookLabel.textColor = Color.blackText
        facebookLabel.numberOfLines = 1
        facebookLabel.adjustsFontSizeToFitWidth = true
        facebookLabel.minimumScaleFactor = 0.7
        
        let emailPaddingLabel = UILabel()
        
        let firstnameField = BorderedTextField()
        let emailField = TaggedTextField(text: "* set by CalNet and cannot be changed")
        let phoneField = BorderedTextField()
        let facebookField = BorderedTextField()
        
        firstnameField.delegate = self
        emailField.textField.delegate = self
        phoneField.delegate = self
        facebookField.delegate = self
        
        firstnameField.autocorrectionType = .no
        phoneField.keyboardType = .phonePad
        facebookField.autocorrectionType = .no
        facebookField.keyboardType = .URL
        
        lvstack.addArrangedSubview(nameLabel)
        lvstack.addArrangedSubview(emailLabel)
        lvstack.addArrangedSubview(emailPaddingLabel)
        lvstack.addArrangedSubview(phoneLabel)
        lvstack.addArrangedSubview(facebookLabel)

        rvstack.addArrangedSubview(firstnameField)
        rvstack.addArrangedSubview(emailField)
        rvstack.addArrangedSubview(phoneField)
        rvstack.addArrangedSubview(facebookField)
        
        firstnameField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 8).isActive = true
        emailField.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 8).isActive = true
        phoneField.leftAnchor.constraint(equalTo: phoneLabel.rightAnchor, constant: 8).isActive = true
        facebookField.leftAnchor.constraint(equalTo: facebookLabel.rightAnchor, constant: 8).isActive = true
        
        firstnameField.rightAnchor.constraint(equalTo: rvstack.rightAnchor).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setHeightConstraint(36)
        nameLabel.leftAnchor.constraint(equalTo: lvstack.leftAnchor).isActive = true
        
        firstnameField.translatesAutoresizingMaskIntoConstraints = false
        firstnameField.setHeightConstraint(36)
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.setHeightConstraint(36)
        
        emailPaddingLabel.translatesAutoresizingMaskIntoConstraints = false
        emailPaddingLabel.setHeightConstraint(2)
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.textField.isUserInteractionEnabled = false
        emailField.setHeightConstraint(50)
        emailField.textField.leftAnchor.constraint(equalTo: rvstack.leftAnchor).isActive = true
        emailField.textField.rightAnchor.constraint(equalTo: rvstack.rightAnchor).isActive = true
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.setHeightConstraint(36)
        
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.setHeightConstraint(36)
        
        facebookLabel.translatesAutoresizingMaskIntoConstraints = false
        facebookLabel.setHeightConstraint(36)
        
        facebookField.translatesAutoresizingMaskIntoConstraints = false
        facebookField.setHeightConstraint(36)
        
        fullNameField = firstnameField
        emailTextField = emailField
    }
    
    @objc private func changeImageButtonPressed(sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ProfileViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // TODO: - Save/update image in backend
            profileImageView.contentMode = .scaleAspectFill
            profileImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
