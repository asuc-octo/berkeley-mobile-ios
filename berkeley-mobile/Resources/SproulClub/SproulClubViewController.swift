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

class SproulClubViewController: UIViewController, WKUIDelegate, UIScrollViewDelegate {
    var webView: WKWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 6).isActive = true
        webView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 6).isActive = true
        webView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -6).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        
        let url = URL(string:"https://www.sproul.club/")
        let request = URLRequest(url: url!)
        webView.load(request)
        
        //disabling zooming and vertical scroll indicator
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
}
