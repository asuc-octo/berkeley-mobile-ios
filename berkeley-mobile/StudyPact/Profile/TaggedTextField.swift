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
    
    var tagBoldStrings: [String] = []
    var tagText: String = ""
    public init(tagText: String, boldStrings: [String] = []) {
        super.init(frame: .zero)
        self.tagText = tagText
        self.tagBoldStrings = boldStrings
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let field = BorderedTextField()
        field.textColor = BMColor.lightLightGrayText
        
        self.addSubview(field)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setHeightConstraint(36)
        field.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        field.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        let label = UILabel()
        label.attributedText = NSAttributedString.boldedText(withString: self.tagText, boldStrings: self.tagBoldStrings, font: Font.regular(10), boldFont: Font.bold(10))
        label.textColor = BMColor.lightGrayText
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setHeightConstraint(14)
        label.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 4).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        textField = field
        tagLabel = label
    }
}
