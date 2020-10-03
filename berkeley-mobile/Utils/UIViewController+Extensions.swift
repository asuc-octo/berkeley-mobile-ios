//
//  UIViewController+Extensions.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/4/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

extension UIViewController {
    public func add(child: UIViewController, frame: CGRect = .zero) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
    public func add(child: UIViewController, toView view: UIView, frame: CGRect = .zero) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = frame
        child.didMove(toParent: self)
    }
    
    // Presents an alert with multiple options and completion handler
    public func presentAlertLinkUrl(title: String, message: String, options: String..., website_url: URL) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            if (index == 0) {
                alertController.addAction(UIAlertAction.init(title: option, style: .cancel))
            } else {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { _ in
                    UIApplication.shared.open(website_url, options: [:])
                }))
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Presents an alert to open phone number
    public func presentAlertLinkTelephone(title: String, message: String, options: String..., phoneNumber: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let number = URL(string: "tel://\(phoneNumber)") else { return }
        
        for (index, option) in options.enumerated() {
            if (index == 0) {
                alertController.addAction(UIAlertAction.init(title: option, style: .cancel))
            } else {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { _ in
                    UIApplication.shared.open(number, options: [:])
                }))
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Presents an alert to open coordinates
    public func presentAlertLinkMaps(title: String, message: String, options: String..., lat: CLLocationDegrees, lon: CLLocationDegrees, name: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let coordinates = CLLocationCoordinate2DMake(lat, lon)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(name)"
        
        for (index, option) in options.enumerated() {
            if (index == 0) {
                alertController.addAction(UIAlertAction.init(title: option, style: .cancel))
            } else {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { _ in
                    mapItem.openInMaps(launchOptions: [:])
                }))
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
