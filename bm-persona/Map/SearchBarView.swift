//
//  SearchBarView.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 11/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import UIKit

class SearchBarView: UIView, UITextFieldDelegate {
    
    open weak var delegate: SearchBarDelegate?
    
    var stackView: UIStackView!
    var textField: MaterialTextField!
    var leftButton: MaterialButton!
    var rightButton: MaterialButton!
    
    var leftButtonImage: UIImage = UIImage(named: "Search")!
        
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSearchBar()
        
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func initSearchBar() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        
        textField = MaterialTextField(hint: "What are you looking for?", textColor: Color.primaryText, font: Font.regular(16.0), bgColor: .white, delegate: self)
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        
        leftButton = MaterialButton(icon: leftButtonImage.colored(.darkGray), textColor: Color.primaryText, font: Font.regular(16), bgColor: .white, cornerRadius: 0.0)
        rightButton = MaterialButton(icon: UIImage(named: "Clear")?.colored(.darkGray), bgColor: .white, cornerRadius: 0.0)
        
        stackView = UIStackView(arrangedSubviews: [leftButton, textField, rightButton])
        stackView.spacing = 0.0
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        setButtonStates(hasInput: false, isSearching: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        leftButton.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.8).isActive = true
        rightButton.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.8).isActive = true
    
    }
    
    // Back or Search button
    @objc private func leftButtonTapped() {
        if leftButton.tag == 1 {
            // Go back
            textField.text = ""
            textFieldDidEndEditing(textField)
        } else {
            textField.becomeFirstResponder()
        }
    }
    
    // Clear Button
    @objc private func rightButtonTapped() {
        textField.text = ""
        rightButton.isHidden = true
    }
    
    // MARK: - Button Handlers
    func setButtonStates(hasInput: Bool, isSearching: Bool) {
        rightButton.isHidden = !hasInput
        changeLeftButton(isSearching)
    }
    
    func changeLeftButton(_ isSearching: Bool) {
        guard leftButton.tag != (isSearching ? 1 : 0) else { return }
        leftButton.tag = isSearching ? 1 : 0
        leftButton.setImage(isSearching ? UIImage(named: "Back")! : leftButtonImage.colored(.darkGray)!, for: .normal)
        
        if !isSearching {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Delegation Implementation
    @objc private func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setButtonStates(hasInput: textField.text?.count != 0, isSearching: true)
        
        // execute search here!
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setButtonStates(hasInput: textField.text?.count != 0, isSearching: true)
        delegate?.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setButtonStates(hasInput: textField.text?.count != 0, isSearching: false)
        delegate?.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setButtonStates(hasInput: textField.text?.count != 0, isSearching: false)
        return delegate?.searchbarTextShouldReturn(textField) ?? true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol SearchBarDelegate: UITextFieldDelegate {
    func searchbarTextDidChange(_ textField: UITextField)
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool
}
