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
    public func presentAlertLinkUrl(title: String, message: String, website_url: URL) {
        
        var alertVC: AlertView!
        
        alertVC = AlertView(headingText: title, messageText: message, action1Label: "Cancel", action1Color: Color.AlertView.secondaryButton, action1Completion: {
            self.dismiss(animated: true, completion: nil)
        }, action2Label: "Yes", action2Color: Color.ActionButton.background, action2Completion: {
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIApplication.shared.open(website_url, options: [:])
            }
        }, withOnlyOneAction: false)

        self.present(alertVC, animated: true, completion: nil)
    }
    
    // Presents an alert to open coordinates
    public func presentAlertLinkMaps(title: String, message: String, lat: CLLocationDegrees, lon: CLLocationDegrees, name: String) {
        
        var alertVC: AlertView!
        
        var query = false
        if lat.isEqual(to: 0.0) || lon.isEqual(to: 0.0) {
            query = true
        }
        
        let coordinates = CLLocationCoordinate2DMake(lat, lon)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        
        alertVC = AlertView(headingText: title, messageText: message, action1Label: "Cancel", action1Color: Color.AlertView.secondaryButton, action1Completion: {
            self.dismiss(animated: true, completion: nil)
        }, action2Label: "Yes", action2Color: Color.ActionButton.background, action2Completion: {
            if query {
                let mapUrl = URL(string: "http://maps.apple.com/?q=\(name.replacingOccurrences(of: " ", with: "+"))")!
                if UIApplication.shared.canOpenURL(mapUrl) {  // People can uninstall the maps app, maybe handle this better in the future
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.open(mapUrl, options: [:])
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mapItem.openInMaps(launchOptions: [:])
                }
            }
        }, withOnlyOneAction: false)

        self.present(alertVC, animated: true, completion: nil)
    }
    
    public func presentSuccessAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    public func presentFailureAlert(title: String, message: String) {
        let alertVC = AlertView(headingText: title, messageText: message, action1Label: "OK", action1Color: Color.ActionButton.background, action1Completion: {
            self.dismiss(animated: true, completion: nil)
        }, action2Label: "", action2Color: UIColor.clear, action2Completion: { return }, withOnlyOneAction: true)

        self.present(alertVC, animated: true, completion: nil)
    }
}
