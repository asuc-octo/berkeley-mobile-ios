//
//  SelectPeopleView.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/28/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class SelectPeopleView: UIView, EnableNextDelegate {
    weak var preferenceVC: CreatePreferenceViewController?
    public init(preferenceVC: CreatePreferenceViewController) {
        self.preferenceVC = preferenceVC
        super.init(frame: .zero)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonGenerator(num: Int) -> UIButton {
        let btn = GroupNumberButton(number: num)
        btn.titleLabel?.font = Font.medium(24)
        btn.setTitleColor(.black, for: .normal)
        btn.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let radius: CGFloat = 22.5
        btn.widthAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.layer.cornerRadius = radius
        btn.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        
        return btn
    }
    
    private var buttonSelected: GroupNumberButton? {
        didSet {
            if let button = buttonSelected {
                isNextEnabled = true
                guard let preferenceVC = self.preferenceVC else { return }
                preferenceVC.preference.numberOfPeople = button.number
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
    
    @objc private func toggleButton(sender: GroupNumberButton) {
        if !sender.isSelected {
            sender.backgroundColor = Color.StudyPact.CreatePreference.selectedPink
            sender.setTitleColor(.white, for: .normal)
            sender.border?.isHidden = true
            sender.isSelected.toggle()
            
            if let buttonSelected = self.buttonSelected {
                buttonSelected.backgroundColor = .white
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                buttonSelected.border?.isHidden = false
                buttonSelected.isSelected.toggle()
            }
            self.buttonSelected = sender
        }
    }
    
    func setUpView() {
        let stackY = UIStackView()
        stackY.axis = .vertical
        stackY.distribution = .equalSpacing
        stackY.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackY)
        
        stackY.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stackY.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        stackY.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        var currentInt = 1
        for _ in 1...2 {
            let stackX = UIStackView()
            stackX.axis = .horizontal
            stackX.distribution = .equalSpacing
            stackX.translatesAutoresizingMaskIntoConstraints = false
            for _ in 1...3 {
                let btn = buttonGenerator(num: currentInt)
                stackX.addArrangedSubview(btn)
                currentInt += 1
            }
            stackY.addArrangedSubview(stackX)
        }
    }
}

private class GroupNumberButton: UIButton {
    let number: Int
    var border: CAShapeLayer?
    init(number: Int) {
        self.number = number
        super.init(frame: .zero)
        self.setTitle(String(number), for: .normal)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if border == nil {
            let bounds = self.bounds
            border = CAShapeLayer.init()
            guard let border = border else { return }
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius)
            border.path = path.cgPath
            border.strokeColor = Color.StudyPact.StudyGroups.createPreferenceDottedBorder.cgColor
            border.lineDashPattern = [2, 2]
            border.fillColor = nil
            self.layer.addSublayer(border)
        }
    }
}
