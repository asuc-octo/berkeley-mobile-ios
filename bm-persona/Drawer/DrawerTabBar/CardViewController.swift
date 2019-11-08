//
//  CardViewController.swift
//  TabBarPoC
//
//  Created by Kevin Hu on 10/30/19.
//  Copyright © 2019 hu. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    private var viewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set up embeded view
        guard let vc = viewController else { return }
        vc.view.backgroundColor = Color.cardBackground
        add(child: vc, frame: view.frame)
        //vc.view.backgroundColor = .green
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        vc.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        vc.view.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        
        vc.view.layer.cornerRadius = 10
        vc.view.layer.shadowColor = UIColor.lightGray.cgColor
        vc.view.layer.shadowOpacity = 0.5
        vc.view.layer.shadowOffset = .zero
        vc.view.layer.shadowRadius = 5
        
        preferredContentSize = vc.preferredContentSize
    }
    
    init(_ vc: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        self.viewController = vc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
