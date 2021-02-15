//
//  SelectEnvironmentView.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class SelectEnvironmentView: UIView, EnableNextDelegate {
    weak var preferenceVC: CreatePreferenceViewController?
    private var buttonSelected: UIButton? {
        didSet {
            if let button = buttonSelected {
                isNextEnabled = true
                guard let preferenceVC = self.preferenceVC else { return }
                preferenceVC.preference.isQuiet = button == quietButton
            } else {
                isNextEnabled = false
            }
        }
    }
    var isNextEnabled: Bool = false {
        didSet {
            guard let preferenceVC = self.preferenceVC else { return }
            preferenceVC.setNextEnabled()
        }
    }
    
    var quietButton: UIButton!
    var collaborativeButton: UIButton!
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Font.regular(16)
        button.titleLabel?.textColor = Color.ActionButton.color
        button.backgroundColor = .white
        
        button.setTitleColor(Color.blackText, for: .normal)
        button.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func toggleButton(sender: ActionButton) {
        if !sender.isSelected {
            sender.backgroundColor = Color.ActionButton.background
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected.toggle()
            if let buttonSelected = self.buttonSelected {
                buttonSelected.backgroundColor = .white
                buttonSelected.isSelected.toggle()
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
            }
            self.buttonSelected = sender
        }
    }
    
    init(preferenceVC: CreatePreferenceViewController) {
        self.preferenceVC = preferenceVC
        super.init(frame: .zero)
        self.quietButton = createButton(title: "Quiet")
        self.collaborativeButton = createButton(title: "Collaborative")
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 25
        stack.distribution = .equalSpacing
        addSubview(stack)
        stack.addArrangedSubview(quietButton)
        stack.addArrangedSubview(collaborativeButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        quietButton.translatesAutoresizingMaskIntoConstraints = false
        collaborativeButton.translatesAutoresizingMaskIntoConstraints = false
        
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.widthAnchor.constraint(equalToConstant: 155).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        quietButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        collaborativeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
