//
//  StudyPactOnboardingViewController.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 10/17/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import UIKit

class StudyPactOnboardingViewController: UIViewController {
    let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.textColor = .white
        label.font = Font.medium(18)
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    let stepLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold(30)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let screenshotBlobView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let screenshotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let blobImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 4
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    let bottomButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.medium(15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 110).isActive = true
        button.heightAnchor.constraint(equalToConstant: 37).isActive = true
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        bottomButton.layer.cornerRadius = bottomButton.frame.height / 2
        numberLabel.layer.cornerRadius = numberLabel.frame.height / 2
    }
    
    @objc func buttonTapped(_: UIButton) {
        if getStarted {
            if let tabBarController = UIApplication.shared.windows.first!.rootViewController as? TabBarController {
                tabBarController.selectProfileTab()
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            pageViewController.moveToNextPage()
        }
    }
    
    var getStarted = false
    var pageViewController: PageViewController
    
    init(stepText: String, themeColor: UIColor, stepNumber: Int, screenshotImage: UIImage, blobImage: UIImage,
         descriptionText: String, pageViewController: PageViewController, boldedStrings: [String] = [],
         getStarted: Bool = false) {
        numberLabel.backgroundColor = themeColor
        numberLabel.text = String(stepNumber)
        stepLabel.text = stepText
        screenshotImageView.image = screenshotImage
        blobImageView.image = blobImage
        descriptionLabel.attributedText = NSAttributedString.boldedText(withString: descriptionText, boldStrings: boldedStrings, font: Font.regular(18), boldFont: Font.bold(18))
        bottomButton.backgroundColor = themeColor
        self.getStarted = getStarted
        self.pageViewController = pageViewController
        super.init(nibName: nil, bundle: nil)
        
        if getStarted {
            bottomButton.setTitle("Let's go!", for: .normal)
        } else {
            bottomButton.setTitle("Next", for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCard()
    }
    
    func setupCard(){
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = view.frame.height * 0.03
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        let numberTitleStack = UIStackView()
        numberTitleStack.axis = .horizontal
        numberTitleStack.distribution = .equalCentering
        numberTitleStack.alignment = .center
        numberTitleStack.spacing = 25
        numberTitleStack.addArrangedSubview(numberLabel)
        numberTitleStack.addArrangedSubview(stepLabel)
        
        stack.addArrangedSubview(screenshotBlobView)
        stack.addArrangedSubview(numberTitleStack)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(bottomButton)
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        
        screenshotBlobView.addSubview(blobImageView)
        screenshotBlobView.addSubview(screenshotImageView)
        screenshotBlobView.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        screenshotBlobView.heightAnchor.constraint(equalTo: screenshotImageView.heightAnchor).isActive = true
        
        screenshotImageView.contentMode = .scaleAspectFit
        screenshotImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35).isActive = true
        screenshotImageView.centerXAnchor.constraint(equalTo: screenshotBlobView.centerXAnchor).isActive = true
        blobImageView.contentMode = .scaleAspectFit
        blobImageView.centerXAnchor.constraint(equalTo: screenshotBlobView.centerXAnchor).isActive = true
        blobImageView.centerYAnchor.constraint(equalTo: screenshotBlobView.centerYAnchor).isActive = true
        blobImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
    }
}

extension NSAttributedString {
    static func boldedText(withString string: String, boldStrings: [String], font: UIFont, boldFont: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
        for boldString in boldStrings {
            let range = (string as NSString).range(of: boldString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        return attributedString
    }
}
