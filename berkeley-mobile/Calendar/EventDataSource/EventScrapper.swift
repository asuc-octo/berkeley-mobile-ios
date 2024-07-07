//
//  EventScrapper.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/6/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import Foundation
import SwiftSoup
import WebKit

protocol EventScrapperDelegate: AnyObject {
    func eventScrapperDidFinishScrapping(results: [EventCalendarEntry])
    func eventScrapperDidError(with errorDescription: String)
}

class EventScrapper: NSObject {
    
    /// Allowed number of rescrapes until `EventScrapper` gives up on scrapping.
    var allowedNumOfRescrapes: Int = 5
    
    private var currNumOfRescrapes: Int = 0
    
    weak var delegate: EventScrapperDelegate?
    
    private var urlString: String!
    
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
        guard let berkCampuswideEventsURL = URL(string: urlString) else {
            return
        }
    
        self.urlString = urlString
        
        webView.load(URLRequest(url: berkCampuswideEventsURL))
    }
}

// MARK: - WKNavigationDelegate
extension EventScrapper: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard currNumOfRescrapes < allowedNumOfRescrapes else {
            currNumOfRescrapes = 0
            delegate?.eventScrapperDidError(with: "Cannot load events in reasonable time. Please try again later.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let htmlContent = result as? String, error == nil else {
                    self.delegate?.eventScrapperDidError(with: error?.localizedDescription ?? "Unrecognized error message")
                    return
                }
                
                do {
                    let doc = try SwiftSoup.parse(htmlContent)
                    
                    let dateElements = try doc.select("div#lw_cal_events > h3")
        
                    var scrappedCalendarEntries = [EventCalendarEntry]()
                    
                    for dateElement in dateElements {
                        let nextDiv = try dateElement.nextElementSibling()
                        let dateString = try dateElement.text()
                        let currentYear = Calendar.current.component(.year, from: Date())
                        
                        if let eventsLink = try nextDiv?.getElementsByClass("lw_cal_event_info"), let dayDate = dateString.convertToDate(dateFormat: "EEEE, MMMM d"), let dateWithYear = Date.setYear(currentYear, to: dayDate) {
                            
                            for eventLink in eventsLink {
                                let locationName = try eventLink.select("div.lw_events_location").text()
                                
                                let eventTimeElement = try eventLink.select("div.lw_events_time")
                                let eventStartTime = try eventTimeElement.select("span.lw_start_time").text()
                                let eventEndTime = try eventTimeElement.select("span.lw_end_time").text()
                                
                                var eventStartTimeDate = eventStartTime.convertTimeStringToDate(baseDate: dateWithYear, endTimeString: eventEndTime)
                                var eventEndTimeDate = eventEndTime.convertTimeStringToDate(baseDate: dateWithYear)
                                
                                // TODO: Parse postfix element
                                if try eventTimeElement.text().contains("All Day") {
                                    eventStartTimeDate = Date.getTodayShiftDate(for: dateWithYear, hourComponent: 0, minuteComponent: 0, secondComponent: 0)
                                    eventEndTimeDate = Date.getTodayShiftDate(for: dateWithYear, hourComponent: 11, minuteComponent: 59, secondComponent: 59)
                                }
                                
                                let eventTitle = try eventLink.select("div.lw_events_title > a").text()
                                // TODO: Insert newlines for pages with blocks
                                let eventSummaryText = try eventLink.select("div.lw_events_summary").text()
                                
                                let eventLinkElement = try eventLink.select("span.lw_item_thumb > a")
                                let eventLinkHrefString = try eventLinkElement.attr("href")
                                let fullSourceLink = eventLinkHrefString.isEmpty ? nil : "https://events.berkeley.edu" + eventLinkHrefString
                                
                                let imageLink = try eventLinkElement.select("picture.lw_image > img").attr("src")
                                                            
                                let newEventCalendarEntry = EventCalendarEntry(name: eventTitle, date: eventStartTimeDate ?? dateWithYear, end: eventEndTimeDate, description: eventSummaryText, location: locationName, imageURL: imageLink, sourceLink: fullSourceLink)
                                scrappedCalendarEntries.append(newEventCalendarEntry)
                            }
                        }
                    }
                    
                    guard !scrappedCalendarEntries.isEmpty else {
                        self.currNumOfRescrapes += 1
                        self.scrape(at: self.urlString)
                        return
                    }
                    
                    self.delegate?.eventScrapperDidFinishScrapping(results: scrappedCalendarEntries)
                } catch {
                    self.delegate?.eventScrapperDidError(with: error.localizedDescription)
                }
            }
        }
    }
    
}
