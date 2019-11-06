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
    
    private var stackView: UIStackView!
    private var textField: MaterialTextField!
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSearchBar()
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func initSearchBar() {
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        textField = MaterialTextField(hint: "What are you looking for?", textColor: Color.primaryText, font: Font.regular(16.0), bgColor: .white, delegate: self)
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        
        stackView = UIStackView(arrangedSubviews: [textField])
        stackView.spacing = 0.0
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    // MARK: - Delegation Implementation
    @objc private func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        delegate?.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        delegate?.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
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
