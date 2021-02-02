//
//  TaggedTextField.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 2/1/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class TaggedTextField: UIView {
    
    var textField: BorderedTextField!
    var tagLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(text: String) {
        self.init()
        tagLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let field = BorderedTextField()
        field.textColor = Color.lightLightGrayText
        
        self.addSubview(field)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setHeightConstraint(36)
        
        let label = UILabel()
        label.text = ""
        label.font = Font.regular(10)
        label.textColor = Color.lightGrayText
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setHeightConstraint(14)
        label.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 4).isActive = true
        
        textField = field
        tagLabel = label
    }

}
