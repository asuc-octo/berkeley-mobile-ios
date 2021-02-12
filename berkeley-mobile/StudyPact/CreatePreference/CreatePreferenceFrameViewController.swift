//
//  CreatePreferenceFrameViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/28/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class CreatePreferenceFrameViewController: UIViewController {
    var questionLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(24)
        label.textAlignment = .center
        label.textColor = Color.blackText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var containedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(labelText: String, containedView: UIView) {
        self.questionLabel.text = labelText
        self.containedView = containedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupToHideKeyboardOnTapOnView()
    }
    
    func setupView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 35
        view.addSubview(stack)
        
        stack.addArrangedSubview(questionLabel)
        stack.addArrangedSubview(containedView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 300/414).isActive = true
        containedView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 35).isActive = true
        containedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 260/896).isActive = true
        containedView.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }
}

extension CreatePreferenceFrameViewController {
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
