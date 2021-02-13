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
import Foundation

class ProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GIDSignInDelegate {
    private var loggedIn = false
    private var loginButton: GIDSignInButton!
    private var berkeleyWarningLabel: UILabel!
    private var logoutButton: UIButton!
    
    private let profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    private var facebookTextField: TaggedTextField!
    private var phoneTextField: BorderedTextField!
    
    private var changeImageButton: UIButton!
    private var imagePicker: UIImagePickerController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.view.backgroundColor = Color.modalBackground
        
        setUpHeader()
        setUpProfile()
        setUpSignIn()
        
        SignInManager.shared.addDelegate(delegate: self)
        
        if SignInManager.shared.isSignedIn {
            loggedInView()
            fillProfile()
        } else {
            loggedOutView()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard user.authentication != nil else {
            loggedOutView()
            return
        }
        // if new sign in to google rather than previous sign in
        if StudyPact.shared.getCryptoHash() == nil {
            StudyPact.shared.registerUser(user: user) { success in
                if !success {
                    self.presentFailureAlert(title: "Failed to Register", message: "Please try again later.")
                    SignInManager.shared.signOut()
                    DispatchQueue.main.async {
                        self.loggedOutView()
                        self.presentFailureAlert(title: "Failed to Sign In", message: "Please try again later.")
                    }
                    return
                }
                self.loggedInView()
                self.fillProfile()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        loggedOutView()
    }
    
    func fillProfile() {
        StudyPact.shared.getUser { data in
            self.fillProfile(data: data)
        } errorCompletion: { error in
            switch error {
            case RequestError.badResponse(let code):
                if code == 400 {
                    guard let user = SignInManager.shared.user else { return }
                    var imageUrl: String?
                    if user.profile.hasImage {
                        imageUrl = user.profile.imageURL(withDimension: 250)?.absoluteString
                    }
                    StudyPact.shared.addUser(name: user.profile.name, email: user.profile.email, phone: nil, profile: imageUrl, facebook: nil) { success in
                        if !success {
                            GIDSignIn.sharedInstance()?.signOut()
                            StudyPact.shared.reset()
                            self.presentFailureAlert(title: "Failed to Register", message: "Please try again later.")
                            DispatchQueue.main.async {
                                self.loggedOutView()
                            }
                        }
                    }
                }
            default:
                return
            }
        }
        
        guard let user = SignInManager.shared.user else { return }
        let fullName = user.profile.name
        let email = user.profile.email
        
        self.initialsLabel.text = String(fullName?.prefix(1) ?? "")
        self.fullNameField.text = fullName
        self.emailTextField.textField.text = email
        
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

extension ProfileViewController {
    func loggedInView() {
        loginButton.isHidden = true
        berkeleyWarningLabel.isHidden = true
        profileView.isHidden = false
        
//        imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
    }
    
    func loggedOutView() {
        loginButton.isHidden = false
        berkeleyWarningLabel.isHidden = false
        profileView.isHidden = true
    }
    
    func setUpHeader() {
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
    
    @objc private func logoutButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Logout?", message: "You will be returned to the login screen.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: {_ in
            let auth = Auth.auth()
            do {
                try auth.signOut()
            } catch let error as NSError {
                // let's hope this never happens and pretend nothing happened
                print("Error signing out: %@", error)
            }
            StudyPact.shared.reset()
            
            self.loggedOutView()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUpProfile() {
        view.addSubview(profileView)
        profileView.leftAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leftAnchor).isActive = true
        profileView.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor).isActive = true
        profileView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        profileView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        profileView.addGestureRecognizer(tap)
        
        profileLabel = UILabel()
        profileLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        profileLabel.numberOfLines = 0
        profileLabel.font = Font.bold(30)
        profileLabel.text = "Profile"
        profileView.addSubview(profileLabel)
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 15).isActive = true
        profileLabel.leftAnchor.constraint(equalTo: profileView.leftAnchor).isActive = true
        
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = Font.medium(18)
        button.setTitleColor(Color.blackText, for: .normal)
        button.setTitleColor(Color.lightGrayText, for: .selected)
        
        profileView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: profileLabel.centerYAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: profileView.rightAnchor).isActive = true
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        
        button.setHeightConstraint(15)
        
        logoutButton = button
        
        let radius: CGFloat = 40
        let initials = ProfileLabel(text: "O", radius: radius, fontSize: 40)
        
        profileView.addSubview(initials)
        
        initials.translatesAutoresizingMaskIntoConstraints = false
        initials.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 15).isActive = true
        initials.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        initials.setHeightConstraint(2 * radius)
        initials.setWidthConstraint(2 * radius)
        
        initialsLabel = initials
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = radius
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        profileView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 15).isActive = true
        imageView.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        imageView.setHeightConstraint(2 * radius)
        imageView.setWidthConstraint(2 * radius)
        
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
        
        let pictureButton = UIButton()
        let attributedString = NSMutableAttributedString(string: "Edit Profile Picture", attributes: regularAttributes)
        pictureButton.setAttributedTitle(attributedString, for: .normal)
        
        let pressedAttributedString = NSMutableAttributedString(string: "Edit Profile Picture", attributes: pressedAttributes)
        pictureButton.setAttributedTitle(pressedAttributedString, for: .selected)
        
        profileView.addSubview(pictureButton)
        pictureButton.translatesAutoresizingMaskIntoConstraints = false
        pictureButton.topAnchor.constraint(equalTo: initials.bottomAnchor, constant: 15).isActive = true
        pictureButton.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        pictureButton.setHeightConstraint(18)
        pictureButton.addTarget(self, action: #selector(changeImageButtonPressed), for: .touchUpInside)
        
        pictureButton.isHidden = true  // TODO: remove in future
        changeImageButton = pictureButton
        
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.distribution = .equalCentering
        hstack.alignment = .center
        
        profileView.addSubview(hstack)
        
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.topAnchor.constraint(equalTo: initialsLabel.bottomAnchor, constant: 20).isActive = true
        hstack.leftAnchor.constraint(equalTo: profileView.leftAnchor, constant: 15).isActive = true
        hstack.rightAnchor.constraint(equalTo: profileView.rightAnchor, constant: -15).isActive = true
        
        let rows = UIStackView()
        rows.axis = .vertical
        rows.distribution = .fill
        rows.alignment = .top
        rows.spacing = 16
        
        hstack.addArrangedSubview(rows)
        
        rows.leftAnchor.constraint(equalTo: profileView.leftAnchor, constant: 15).isActive = true
        rows.rightAnchor.constraint(equalTo: profileView.rightAnchor, constant: -15).isActive = true
        
        
        // ** NAME SECTION ** //
        let nameRow = UIStackView()
        nameRow.axis = .horizontal
        nameRow.distribution = .fill
        nameRow.alignment = .center
        nameRow.spacing = 8
        
        rows.addArrangedSubview(nameRow)
        
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = Font.medium(14)
        nameLabel.textAlignment = .left
        nameLabel.textColor = Color.blackText
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
        
        let firstnameField = BorderedTextField()
        firstnameField.delegate = self
        firstnameField.autocorrectionType = .no
        
        nameRow.addArrangedSubview(nameLabel)
        nameRow.addArrangedSubview(firstnameField)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setHeightConstraint(36)
        nameLabel.setWidthConstraint(100)
        nameLabel.leftAnchor.constraint(equalTo: rows.leftAnchor).isActive = true
        
        firstnameField.translatesAutoresizingMaskIntoConstraints = false
        firstnameField.rightAnchor.constraint(equalTo: rows.rightAnchor).isActive = true
        firstnameField.setHeightConstraint(36)
        
        
        // ** EMAIL SECTION ** //
        let emailRow = UIStackView()
        emailRow.axis = .horizontal
        emailRow.distribution = .fill
        emailRow.alignment = .center
        emailRow.spacing = 8
        
        rows.addArrangedSubview(emailRow)
        
        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.font = Font.medium(14)
        emailLabel.textAlignment = .left
        emailLabel.textColor = Color.blackText
        emailLabel.numberOfLines = 1
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.7
        
        emailRow.addArrangedSubview(emailLabel)

        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.setWidthConstraint(100)
        emailLabel.setHeightConstraint(36)
        emailLabel.leftAnchor.constraint(equalTo: rows.leftAnchor).isActive = true

        let emailField = TaggedTextField(text: "* set by CalNet and cannot be changed")
        emailField.textField.delegate = self
        
        emailRow.addArrangedSubview(emailField)

        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.textField.isUserInteractionEnabled = false
        emailField.setHeightConstraint(50)
        emailField.rightAnchor.constraint(equalTo: rows.rightAnchor).isActive = true

        
        // ** PHONE SECTION ** //
        let phoneRow = UIStackView()
        phoneRow.axis = .horizontal
        phoneRow.distribution = .fill
        phoneRow.alignment = .center
        phoneRow.spacing = 8
        
        rows.addArrangedSubview(phoneRow)
        
        let phoneLabel = UILabel()
        phoneLabel.text = "Phone Number"
        phoneLabel.font = Font.medium(14)
        phoneLabel.textAlignment = .left
        phoneLabel.textColor = Color.blackText
        phoneLabel.numberOfLines = 1
        phoneLabel.adjustsFontSizeToFitWidth = true
        phoneLabel.minimumScaleFactor = 0.7
        
        phoneRow.addArrangedSubview(phoneLabel)
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.setWidthConstraint(100)
        phoneLabel.setHeightConstraint(36)
        phoneLabel.leftAnchor.constraint(equalTo: rows.leftAnchor).isActive = true
        
        let phoneField = BorderedTextField()
        phoneField.delegate = self
        phoneField.keyboardType = .phonePad
        
        phoneRow.addArrangedSubview(phoneField)

        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.setHeightConstraint(36)
        phoneField.rightAnchor.constraint(equalTo: rows.rightAnchor).isActive = true

        phoneTextField = phoneField

        // ** FACEBOOK SECTION ** //
        let fbRow = UIStackView()
        fbRow.axis = .horizontal
        fbRow.distribution = .fill
        fbRow.alignment = .center
        fbRow.spacing = 8
        
        rows.addArrangedSubview(fbRow)
        
        let facebookLabel = UILabel()
        facebookLabel.text = "Facebook Username"
        facebookLabel.numberOfLines = 2
        facebookLabel.font = Font.medium(14)
        facebookLabel.textAlignment = .left
        facebookLabel.textColor = Color.blackText
        facebookLabel.adjustsFontSizeToFitWidth = true
        facebookLabel.minimumScaleFactor = 0.7

        fbRow.addArrangedSubview(facebookLabel)
        
        facebookLabel.translatesAutoresizingMaskIntoConstraints = false
        facebookLabel.setWidthConstraint(100)
        facebookLabel.setHeightConstraint(36)
        facebookLabel.leftAnchor.constraint(equalTo: rows.leftAnchor).isActive = true
        
        let facebookField = TaggedTextField(text: "facebook.com/your-username")
        facebookField.textField.delegate = self
        facebookField.textField.autocorrectionType = .no
        facebookField.textField.keyboardType = .URL
        facebookField.textField.textColor = Color.blackText
        
        fbRow.addArrangedSubview(facebookField)

        facebookField.translatesAutoresizingMaskIntoConstraints = false
        facebookField.setHeightConstraint(50)
        facebookField.rightAnchor.constraint(equalTo: rows.rightAnchor).isActive = true
        
        fullNameField = firstnameField
        emailTextField = emailField
        facebookTextField = facebookField
        
        // ** BUTTONS ** //
        let cancelButton = ActionButton(title: "Cancel", font: Font.bold(14), defaultColor: Color.StudyPact.StudyGroups.leaveGroupButton, pressedColor: Color.StudyPact.StudyGroups.leaveGroupButton)
        cancelButton.layer.shadowRadius = 2.5
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        profileView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.leftAnchor.constraint(equalTo: profileView.leftAnchor).isActive = true
        cancelButton.setHeightConstraint(40)
        cancelButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -10).isActive = true
        
        let saveButton = ActionButton(title: "Save", font: Font.bold(14))
        saveButton.layer.shadowRadius = 2.5
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        
        profileView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: profileView.rightAnchor).isActive = true
        saveButton.setHeightConstraint(40)
        saveButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -10).isActive = true
        
        cancelButton.rightAnchor.constraint(equalTo: saveButton.leftAnchor, constant: -23).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor).isActive = true
    }
    
    func setUpSignIn() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        loginButton = GIDSignInButton()
        
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let warningLabel = UILabel()
        warningLabel.text = "You must use a valid berkeley.edu email"
        warningLabel.font = Font.medium(14)
        warningLabel.numberOfLines = 1
        warningLabel.adjustsFontSizeToFitWidth = true
        warningLabel.minimumScaleFactor = 0.7
        warningLabel.textColor = Color.lightGrayText
        warningLabel.textAlignment = .center
        
        view.addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 25).isActive = true
        warningLabel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        warningLabel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        berkeleyWarningLabel = warningLabel
    }
    
    @objc private func cancelButtonPressed(sender: UIButton) {
        fullNameField.setDefault()
        phoneTextField.setDefault()
        facebookTextField.textField.setDefault()
        
        // Get user info from backend
        StudyPact.shared.getUser { data in
            self.fillProfile(data: data)
        }
    }
    
    private func fillProfile(data: [String: Any]?) {
        guard let data = data,
              let info = data["info"] as? [String : String] else { return }
        self.emailTextField.textField.text = data["user_email"] as? String
        
        self.fullNameField.text = info["name"]
        if let phone = info["phone"] {
            self.phoneTextField.text = phone
        } else {
            self.phoneTextField.text = ""
        }
        if let fb = info["facebook"] {
            self.facebookTextField.textField.text = fb
        } else {
            self.facebookTextField.textField.text = ""
        }
        if let url = info["profile_picture"] {
            guard let imageUrl = URL(string: url) else { return }
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
    
    @objc private func saveButtonPressed(sender: UIButton) {
        let name = fullNameField.text
        let facebook = validateFacebook(text: facebookTextField.textField.text ?? "")
        let phoneNumber = validatePhoneNumber(text: phoneTextField.text ?? "")
        
        var hasInvalid = false
        if name == "" {
            hasInvalid = true
            fullNameField.setInvalid()
        }
        if facebookTextField.textField.text != "" && facebook == nil {
            hasInvalid = true
            facebookTextField.textField.setInvalid()
        }
        if phoneTextField.text != "" && phoneNumber == nil {
            hasInvalid = true
            phoneTextField.setInvalid()
        }
        if hasInvalid {
            return
        }
        fullNameField.setDefault()
        phoneTextField.setDefault()
        facebookTextField.textField.setDefault()
        
        // Adds updated user
        let imageUrl = SignInManager.shared.user?.profile.imageURL(withDimension: 250)?.absoluteString
        StudyPact.shared.addUser(name: fullNameField.text!, email: StudyPact.shared.email!, phone: phoneNumber, profile:
                                 imageUrl, facebook: facebook) { (success) in
            if success {
                self.presentSuccessAlert(title: "Successfully saved profile")
            } else {
                self.presentFailureAlert(title: "Failed to Save Profile", message: "Please try again later.")
            }
        }
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

extension ProfileViewController {
    func validateFacebook(text: String) -> String? {
        if text.isValidFacebook && text.count >= 5 {
            return text
        }
        return nil
    }
    
    func validatePhoneNumber(text: String) -> String? {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text)) {
            return text
        } else {
            return nil
        }
    }
}

extension String {
    var isValidFacebook: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9.]", options: .regularExpression) == nil
    }
}
