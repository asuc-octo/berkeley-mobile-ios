//
//  MissingDataView.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

class MissingDataView: UIView {
    
    private var missingLabel: UILabel!

    init(text: String) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = Color.cardBackground
        
        let label = UILabel()
        label.textColor = Color.darkGrayText
        label.textAlignment = .center
        label.font = Font.medium(18)
        label.text = text
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)

        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        missingLabel = label
    }
    
    convenience init(parentView: UIView, text: String) {
        self.init(text: text)
        
        self.isHidden = true
        parentView.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: parentView.layoutMarginsGuide.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: parentView.layoutMarginsGuide.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: parentView.layoutMarginsGuide.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
