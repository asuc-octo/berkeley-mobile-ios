//
//  RSFScrapper.swift
//  berkeley-mobile
//
//  Created by Dylan Chhum on 12/3/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import Foundation
import SwiftSoup
import WebKit

protocol RSFScrapperDelegate: AnyObject {
    func rsfScrapperDidFinishScrapping(result: String?)
    func rsfScrapperDidError(with errorDescription: String)
}

class RSFScrapper: NSObject {
    
    struct Constants {
        static let weightRoomURLString = "https://safe.density.io/#/displays/dsp_956223069054042646?token=shr_o69HxjQ0BYrY2FPD9HxdirhJYcFDCeRolEd744Uj88e&share&qr"
    }
    
    /// Allowed number of rescrapes until `RSFScrapper` gives up on scrapping.
    var allowedNumOfRescrapes: Int = 5
    
    private var currNumOfRescrapes: Int = 0
    private var timer: Timer?
    
    weak var delegate: RSFScrapperDelegate?
    
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
    
    // TODO: Add helper public methods to access occupancy
    
    func getOccupancy() -> String {
        scrape(at: Constants.weightRoomURLString)
        return (occupancyText ?? "Not working")
    }
    
}


// MARK: - WKNavigationDelegate

extension RSFScrapper: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard currNumOfRescrapes < allowedNumOfRescrapes else {
            currNumOfRescrapes = 0
            delegate?.rsfScrapperDidError(with: "Cannot load events in reasonable time. Please try again later.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let htmlContent = result as? String, error == nil else {
                    self.delegate?.rsfScrapperDidError(with: error?.localizedDescription ?? "Unrecognized error message")
                    return
                }
                
                do {
                    let doc = try SwiftSoup.parse(htmlContent)
                    
                    if let weightOccupancyText = try doc.select("div.styles_fullness__rayxl > span").first()?.text() {
                        print("Weight Occupancy: \(weightOccupancyText)")
                        self.delegate?.rsfScrapperDidFinishScrapping(result: weightOccupancyText)
                        self.occupancyText = weightOccupancyText
    
                    } else {
                        print("Unable to find weight occupancy text")
                        if let urlString = self.urlString {
                            self.currNumOfRescrapes += 1
                            self.scrape(at: urlString)
                        }
                    }
                } catch {
                    self.delegate?.rsfScrapperDidError(with: error.localizedDescription)
                }
            }
        }
    }
    
}
