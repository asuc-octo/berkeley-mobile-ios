//
//  ClassSearch-SPOnboardingViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ClassSearch_SPOnboardingViewController: UIView, UITextFieldDelegate {

    
    var model: SPData!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setUpView() {
        
        let textField = MaterialTextField(hint: "Search for a class", textColor: Color.darkGrayText, font: Font.regular(15), bgColor: Color.searchBarBackground, delegate: self)
        textField.cornerRadius = 15.0
        textField.setCornerBorder(color: Color.searchBarBackground, cornerRadius: 15.0, borderWidth: 0.0)
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.layer.masksToBounds = false
        textField.padding = CGSize(width: 10, height: 0)
        
        textField.layer.shadowRadius = 5
        textField.layer.shadowOpacity = 0.25
        textField.layer.shadowOffset = .zero
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
}

extension StudyPactSetupViewController {
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
}
