//
//  CovidResourceViewController.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 10/31/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class CovidResourceViewController: UIViewController {
    private var overviewStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        covidOverview()
    }
}

extension CovidResourceViewController {
    func covidOverview() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 9
        
        let uhsTests = createOverviewCard(cardHeader: "UHS Tests", cardValue: 4235)
        let positiveTests = createOverviewCard(cardHeader: "Positive Tests", cardValue: 6)
        
        stack.addArrangedSubview(uhsTests)
        stack.addArrangedSubview(positiveTests)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: kViewMargin * 3).isActive = true
        stack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        overviewStack = stack
    }
    
    func createOverviewCard(cardHeader: String, cardValue: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = Color.selectedButtonBackground.cgColor
                
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.alignment = .center
        cardStack.distribution = .fill
        cardStack.spacing = 24
        cardStack.layoutMargins = UIEdgeInsets(top: 19, left: 0, bottom: 19, right: 0)
        cardStack.isLayoutMarginsRelativeArrangement = true
        
        let headerLabel = UILabel()
        headerLabel.text = cardHeader
        headerLabel.font = Font.medium(24)
        headerLabel.textAlignment = .center
        headerLabel.textColor = Color.selectedButtonBackground
                
        let valueLabel = UILabel()
        valueLabel.text = String(cardValue)
        valueLabel.font = Font.bold(45)
        valueLabel.textAlignment = .center
        valueLabel.textColor = Color.selectedButtonBackground
        
        view.addSubview(cardStack)
        cardStack.addArrangedSubview(headerLabel)
        cardStack.addArrangedSubview(valueLabel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cardStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cardStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cardStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }
}
