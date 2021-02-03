//
//  ProfileLabel.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class ProfileLabel: UILabel {
    init(text: String, radius: CGFloat, fontSize: CGFloat) {
        super.init(frame: .zero)
        
        self.text = text
        self.textAlignment = .center
        self.font = Font.bold(fontSize)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.backgroundColor = Color.StudyPact.Profile.defaultProfileBackground
        self.textColor = Color.StudyPact.Profile.defaultProfileLetter
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
