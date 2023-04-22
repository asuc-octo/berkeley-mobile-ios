//
//  SafetyResourceViewController.swift
//  berkeley-mobile
//
//  Created by Sydney Tsai on 11/18/22.
//  Copyright © 2022 ASUC OCTO. All rights reserved.
//

import UIKit
import Firebase

class SafetyResourceViewController: UIViewController {
    private var button: UIButton = {
        let button = UIButton(type: .custom)
        let xPostion:CGFloat = 50
        let yPostion:CGFloat = 100
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 150

        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        
        button.backgroundColor = UIColor.systemRed
        button.setTitle("Need Help?", for: UIControl.State.normal)
//        button.frame = CGRect(x: 160, y: 100, width: 100, height: 100)
//        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    @objc func buttonAction(_ sender:UIButton!)
    {
        print("Button tapped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}
