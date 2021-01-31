//
//  PeopleCountPicker-SPOnboarding.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/28/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class PeopleCountPicker_SPOnboarding: UIView {

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
    
    
    func buttonGenerator(num: Int) -> UIButton {
        
        let btn = UIButton()
        btn.setTitle(String(num), for: .normal)
        btn.titleLabel?.font = Font.medium(24)
        btn.setTitleColor(.black, for: .normal)
        btn.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.widthAnchor.constraint(equalToConstant: 45).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        
//        let yourViewBorder = CAShapeLayer()
//        yourViewBorder.strokeColor = UIColor.black.cgColor
//        yourViewBorder.lineDashPattern = [2, 2]
//        yourViewBorder.frame = btn.bounds
//        yourViewBorder.fillColor = nil
//        yourViewBorder.path = UIBezierPath(rect: btn.bounds).cgPath
//        btn.layer.addSublayer(yourViewBorder)
        
        return btn
    }
    
    var buttonSelected: UIButton!
    @objc func toggleButton(sender: UIButton) {
        //When the button has already been selected
        print("Button clicked")
        if sender.isSelected {
            sender.backgroundColor = .white
            sender.setTitleColor(Color.blackText, for: .normal)
            sender.isSelected.toggle()
            
            if buttonSelected != nil {
                buttonSelected.backgroundColor = .white
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                
                if buttonSelected != sender {
                    sender.backgroundColor = Color.selectedPink
                    sender.setTitleColor(.white, for: .normal)
                }
                buttonSelected = sender
            } else {
                buttonSelected = nil
            }
            
        } else {
            sender.backgroundColor = Color.selectedPink
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected.toggle()
            
            if buttonSelected != nil {
                buttonSelected.backgroundColor = .white
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                
                sender.backgroundColor = Color.selectedPink
                sender.setTitleColor(.white, for: .normal)
            }
            buttonSelected = sender
        }
        
        
    }
    
    
    func setUpView() {
        
        let stackY = UIStackView()
        stackY.axis = .vertical
        stackY.spacing = 30
        stackY.distribution = .fillEqually
        stackY.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackY)
        
        stackY.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        stackY.heightAnchor.constraint(equalTo: heightAnchor, constant: -10).isActive = true
        
        var currentInt = 1
        for _ in 1...2 {
            let stackX = UIStackView()
            stackX.axis = .horizontal
            stackX.spacing = 45
            stackX.distribution = .fillEqually
            stackX.translatesAutoresizingMaskIntoConstraints = false
            stackX.heightAnchor.constraint(equalToConstant: 45).isActive = true
            for _ in 1...3 {
                let btn = buttonGenerator(num: currentInt)
                stackX.addArrangedSubview(btn)
                currentInt += 1
                print(currentInt)
            }
            stackY.addArrangedSubview(stackX)
        }
    }

}

