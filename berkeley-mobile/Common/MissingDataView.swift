//
//  MissingDataView.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 4/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

protocol MissingDataViewDelegate: AnyObject {
    func missingDataViewDidReload()
}

class MissingDataView: UIView {
    
    weak var delegate: MissingDataViewDelegate?
    
    private var missingLabel: UILabel!
    
    init(text: String) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = BMColor.cardBackground
        
        let label = UILabel()
        label.textColor = BMColor.darkGrayText
        label.textAlignment = .center
        label.font = BMFont.medium(18)
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
    
    func showReloadButton(withTitle title: String) {
        let reloadButton = ActionButton(title: title)
        reloadButton.addTarget(self, action: #selector(reloadData), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reloadButton)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            reloadButton.topAnchor.constraint(equalTo: missingLabel.bottomAnchor, constant: padding),
            reloadButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            reloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            reloadButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

    @objc private func reloadData() {
        delegate?.missingDataViewDidReload()
    }
}
