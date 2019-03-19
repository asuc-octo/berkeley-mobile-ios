//
//  TappableInfoTableViewCell.swift
//  berkeleyMobileiOS
//
//  Created by Kevin Hu on 11/4/18.
//  Copyright © 2018 org.berkeleyMobile. All rights reserved.
//

import UIKit
import MessageUI

enum TappableInfoType {
    case phone
    case email
    case website
    case none
    
    static func formattedAs(_ type: TappableInfoType, str: String?) -> Bool {
        let regex: String
        switch type {
        case .phone:
            regex = "(\\+\\d{1,2}\\s?)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]{0,3}\\d{4}"
        case .email:
            regex = "[^\\s@]+@[^\\s@]+.[^\\s@]+"
        case .website:
            regex = "[^\\s@]+.[^\\s@]+"
        default:
            return true
        }
        
        return str?.range(of: regex, options: .regularExpression) != nil
    }
}

class TappableInfoTableViewCell: UITableViewCell {
    
    var delegate: (UIViewController & MFMailComposeViewControllerDelegate)?
    var type = TappableInfoType.none
    var info: String!
    
    func didTap() {
        if info == nil || !TappableInfoType.formattedAs(type, str: info) {
            return
        }
        
        switch type {
        case .phone:
            call(number: info)
        case .email:
            email(address: info)
        case .website:
            website(address: info)
        default:
            return
        }
    }
    
    func call(number: String) {
        let formatted = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let number = URL(string: "tel://" + formatted),
            UIApplication.shared.canOpenURL(number) {
            UIApplication.shared.open(number)
        }
    }
    
    func email(address: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = delegate
            mail.setToRecipients([address])
            delegate?.present(mail, animated: true)
        }
    }
    
    func website(address: String) {
        if let website = URL(string: "http://" + address),
            UIApplication.shared.canOpenURL(website) {
            UIApplication.shared.open(website)
        }
    }
}
