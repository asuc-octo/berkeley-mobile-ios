//
//  WhereToStudy-SPOnboarding.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class WhereToStudy_SPOnboarding: UIView {

    var buttonSelected: UIButton!
    var model: SPData!
    
    let virtualButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        button.setTitle("Virtual", for: .normal)
        button.titleLabel?.font = Font.regular(16)
        button.titleLabel?.textColor = Color.ActionButton.color
        button.backgroundColor = .white
        
        button.setTitleColor(Color.blackText, for: .normal)
        button.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    let inPersonButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        button.setTitle("In Person", for: .normal)
        button.titleLabel?.font = Font.regular(16)
        button.titleLabel?.textColor = Color.ActionButton.color
        button.backgroundColor = .white
        
        button.setTitleColor(Color.blackText, for: .normal)
        button.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc func toggleButton(sender: ActionButton) {
        //When the button has already been selected
        if sender.isSelected {
            sender.backgroundColor = .white
            sender.setTitleColor(Color.blackText, for: .normal)
            sender.isSelected.toggle()
            
            if buttonSelected != nil {
                buttonSelected.backgroundColor = .white
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                
                if buttonSelected != sender {
                    sender.backgroundColor = Color.ActionButton.background
                    sender.setTitleColor(.white, for: .normal)
                }
                buttonSelected = sender
            } else {
                buttonSelected = nil
            }
            print("Going from blue to white", "buttonSelected is now:", buttonSelected?.titleLabel?.text ?? "nil")
            
        } else {
            sender.backgroundColor = Color.ActionButton.background
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected.toggle()
            
            if buttonSelected != nil {
                buttonSelected.backgroundColor = .white
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                
                sender.backgroundColor = Color.ActionButton.background
                sender.setTitleColor(.white, for: .normal)
            }
            buttonSelected = sender
            print("Going from white to blue", "buttonSelected is now:", buttonSelected?.titleLabel?.text ?? "nil")
        }
    }
    
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
