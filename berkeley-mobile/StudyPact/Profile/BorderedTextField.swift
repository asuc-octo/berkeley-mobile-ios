//
//  BorderedTextField.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/23/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class BorderedTextField: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 10,
        bottom: 0,
        right: 0
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = BMColor.lightLightGrayText.cgColor
        self.layer.borderWidth = 2
        self.font = Font.medium(14)
        self.textColor = BMColor.blackText
        self.adjustsFontSizeToFitWidth = false
        self.textAlignment = .left
        self.returnKeyType = .done
    }
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    
    func setInvalid() {
        self.layer.borderColor = BMColor.highOccupancyTag.cgColor
    }
    
    func setDefault() {
        self.layer.borderColor = BMColor.lightLightGrayText.cgColor
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
