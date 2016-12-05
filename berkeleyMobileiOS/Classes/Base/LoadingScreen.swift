//
//  LoadingScreen.swift
//  berkeleyMobileiOS
//
//  Created by Maya Reddy on 12/4/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

class LoadingScreen: NSObject {
    let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    let loadScreen = UIView.init(frame: UIScreen.main.bounds)
    
    static let sharedInstance = LoadingScreen()
    private override init() {
        loadScreen.backgroundColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
        loadScreen.addSubview(activityView)
        activityView.hidesWhenStopped = true;
    }
    
    // return loading screen
    
    func getLoadingScreen() -> UIView {
        activityView.isHidden = false;
        let height = UIScreen.main.bounds.size.height / 2;
        let width = UIScreen.main.bounds.size.width / 2;
        activityView.center = CGPoint.init(x: width, y: height);
        loadScreen.bringSubview(toFront: activityView)
        activityView.startAnimating()
        return loadScreen;
    }
    
    // removes loading screen
    func removeLoadingScreen() {
        activityView.stopAnimating()
        loadScreen.removeFromSuperview()
    }

}
