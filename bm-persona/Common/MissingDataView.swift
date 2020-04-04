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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.textColor = Color.darkGrayText
        label.textAlignment = .center
        label.font = Font.medium(18)
        label.text = "Looks like we don't have any data"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.center = self.center
        
        self.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        missingLabel = label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
