//
//  SelectLocationView.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class SelectLocationView: UIView, EnableNextDelegate {
    let preferenceVC: CreatePreferenceViewController
    private var buttonSelected: UIButton? {
        didSet {
            if let button = buttonSelected {
                isNextEnabled = true
                preferenceVC.preference.isVirtual = button == virtualButton
            } else {
                isNextEnabled = false
            }
        }
    }
    var isNextEnabled: Bool = false {
        didSet {
            preferenceVC.setNextEnabled()
        }
    }
    
    var virtualButton: UIButton!
    var inPersonButton: UIButton!
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
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                sender.backgroundColor = Color.ActionButton.background
                sender.setTitleColor(.white, for: .normal)
            }
            self.buttonSelected = sender
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    init(preferenceVC: CreatePreferenceViewController) {
        self.preferenceVC = preferenceVC
        super.init(frame: .zero)
        self.virtualButton = createButton(title: "Virtual")
        self.inPersonButton = createButton(title: "In Person")
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
        stack.addArrangedSubview(virtualButton)
        stack.addArrangedSubview(inPersonButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        virtualButton.translatesAutoresizingMaskIntoConstraints = false
        inPersonButton.translatesAutoresizingMaskIntoConstraints = false
        
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.widthAnchor.constraint(equalToConstant: 155).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        virtualButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        inPersonButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
