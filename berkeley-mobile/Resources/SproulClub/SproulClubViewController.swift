//
//  SproulClubViewController.swift
//  berkeley-mobile
//
//  Created by Kevin Wang on 3/26/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SproulClubViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
        
        override func loadView() {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            
            view = webView
        }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            let myURL = URL(string:"https://www.sproul.club/")
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
            
            //disable zooming in
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
        }
    
}
