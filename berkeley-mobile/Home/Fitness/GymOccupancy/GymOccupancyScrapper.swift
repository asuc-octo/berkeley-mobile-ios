//
//  GymOccupancyScrapper.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 12/3/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import Foundation
import SwiftSoup
import WebKit

protocol GymOccupancyScrapperDelegate: AnyObject {
    func scrapperDidFinishScrapping(result: String?)
    func scrapperDidError(with errorDescription: String)
}

class GymOccupancyScrapper: NSObject {
    
    /// Allowed number of rescrapes until `GymOccupancyScrapper` gives up on scrapping.
    var allowedNumOfRescrapes: Int = 5
    
    private var currNumOfRescrapes: Int = 0
    private var timer: Timer?
    
    weak var delegate: GymOccupancyScrapperDelegate?
    
    private var occupancyText : String?
    
    private var urlString: String?
    
    private let webView: WKWebView = {
        let prefs = WKPreferences()
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    override init() {
        super.init()
        webView.navigationDelegate = self
    }
    
    func scrape(at urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
    
        self.urlString = urlString
        
        webView.load(URLRequest(url: url))
    }
    
}


// MARK: - WKNavigationDelegate

extension GymOccupancyScrapper: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard currNumOfRescrapes < allowedNumOfRescrapes else {
            currNumOfRescrapes = 0
            delegate?.scrapperDidError(with: "Cannot load events in reasonable time. Please try again later.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let htmlContent = result as? String, error == nil else {
                    self.delegate?.scrapperDidError(with: error?.localizedDescription ?? "Unrecognized error message")
                    return
                }
                
                do {
                    let doc = try SwiftSoup.parse(htmlContent)
                    
                    if let weightOccupancyText = try doc.select("div.styles_fullness__rayxl > span").first()?.text() {
                        self.delegate?.scrapperDidFinishScrapping(result: weightOccupancyText)
                        self.occupancyText = weightOccupancyText
    
                    } else {
                        if let urlString = self.urlString {
                            self.currNumOfRescrapes += 1
                            self.scrape(at: urlString)
                        }
                    }
                } catch {
                    self.delegate?.scrapperDidError(with: error.localizedDescription)
                }
            }
        }
    }
    
}
