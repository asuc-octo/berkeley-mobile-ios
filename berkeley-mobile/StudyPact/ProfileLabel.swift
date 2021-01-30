//
//  ProfileLabel.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ProfileLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.text = "OB"
        self.textAlignment = .center
        self.font = Font.bold(40)
        self.layer.cornerRadius = 50
        self.layer.masksToBounds = true
        self.backgroundColor = Color.lightGrayText
        self.textColor = UIColor.white
    }
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
