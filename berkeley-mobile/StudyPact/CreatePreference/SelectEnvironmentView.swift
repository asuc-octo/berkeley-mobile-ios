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
    let quietLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium(13)
        label.text = "study alone, but keep each other accountable"
        label.textAlignment = .center
        label.textColor = BMColor.StudyPact.CreatePreference.grayText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    var collaborativeButton: UIButton!
    let collaborativeLabel: UILabel = {
        let label = UILabel()
        label.font = Font.medium(13)
        label.text = "work together to finish tasks"
        label.textAlignment = .center
        label.textColor = BMColor.StudyPact.CreatePreference.grayText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 12
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Font.medium(16)
        button.backgroundColor = BMColor.modalBackground
        
        button.setTitleColor(BMColor.StudyPact.CreatePreference.grayText, for: .normal)
        button.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 125).isActive = true
        
        return button
    }
    
    @objc func toggleButton(sender: ActionButton) {
        if !sender.isSelected {
            sender.backgroundColor = BMColor.StudyPact.CreatePreference.selectedBlue
            sender.setTitleColor(BMColor.primaryText, for: .normal)
            sender.isSelected.toggle()
            if let buttonSelected = self.buttonSelected {
                buttonSelected.backgroundColor = BMColor.modalBackground
                buttonSelected.isSelected.toggle()
                buttonSelected.setTitleColor(BMColor.StudyPact.CreatePreference.grayText, for: .normal)
                switch buttonSelected {
                case quietButton:
                    quietLabel.textColor = BMColor.StudyPact.CreatePreference.grayText
                case collaborativeButton:
                    collaborativeLabel.textColor = BMColor.StudyPact.CreatePreference.grayText
                default:
                    break
                }
            }
            self.buttonSelected = sender
            switch sender {
            case quietButton:
                quietLabel.textColor = BMColor.StudyPact.CreatePreference.selectedBlue
            case collaborativeButton:
                collaborativeLabel.textColor = BMColor.StudyPact.CreatePreference.selectedBlue
            default:
                break
            }
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
        stack.axis = .horizontal
        stack.spacing = 15
        stack.distribution = .equalSpacing
        addSubview(stack)
        
        stack.addArrangedSubview(buttonLabelVerticalPair(button: quietButton, label: quietLabel))
        stack.addArrangedSubview(buttonLabelVerticalPair(button: collaborativeButton, label: collaborativeLabel))
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func buttonLabelVerticalPair(button: UIButton, label: UILabel) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.addSubview(label)
        button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 15).isActive = true
        label.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
        return view
    }
}
