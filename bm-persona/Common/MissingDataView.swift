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
        label.text = "No items found"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)

        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        missingLabel = label
    }
    
    func setupMissingView(parentView: UIView) {
        let view = MissingDataView()
        
        view.isHidden = false
        parentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: parentView.layoutMarginsGuide.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: parentView.layoutMarginsGuide.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: parentView.layoutMarginsGuide.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
