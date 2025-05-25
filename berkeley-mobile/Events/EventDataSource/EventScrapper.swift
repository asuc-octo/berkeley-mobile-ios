//
//  EventScrapper.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/6/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import SwiftSoup
import SwiftUI
import WebKit

class EventScrapper: NSObject, ObservableObject {
    enum EventScrapperType {
        case academic
        case campuswide
        
        func getInfo() -> (URLString: String, lastRefreshDateKey: String) {
            switch self {
            case .academic:
                return ("https://events.berkeley.edu/events/week/categories/Academic", UserDefaultsKeys.academicEventsLastSavedDate.rawValue)
            case .campuswide:
                return ("https://events.berkeley.edu/events/all", UserDefaultsKeys.campuswideEventsLastSavedDate.rawValue)
            }
        }
    }
    
    @Published var entries: [Date: [BMEventCalendarEntry]] = [:]
    @Published var isLoading = false
    @Published var alert: BMAlert?
    
    var groupedEntriesSortedKeys: [Date] {
        entries.keys.sorted()
    }
    
    /// Allowed number of rescrapes until `EventScrapper` gives up on scrapping.
    private var allowedNumOfRescrapes = 5
    private var currNumOfRescrapes = 0
    private var type: EventScrapperType!
    private var cachedSavedGroupedEvents: [Date: [BMEventCalendarEntry]] = [:]
    
    lazy private var webView: WKWebView = {
        let prefs = WKPreferences()
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    init(type: EventScrapperType, allowedNumOfRescrapes: Int = 5) {
        super.init()
        self.allowedNumOfRescrapes = allowedNumOfRescrapes
        self.type = type
        webView.navigationDelegate = self
    }
    
    func scrape(forceRescrape: Bool = false) {
        guard let url = URL(string: type.getInfo().URLString) else {
            return
        }
    
        isLoading = true
        
        entries.removeAll()
        
        let rescrapeInfo = getRescrapeInfo(force: forceRescrape)
        
        if rescrapeInfo.shouldRescrape {
            webView.load(URLRequest(url: url))
        } else {
            entries = rescrapeInfo.savedGroupedEvents
            isLoading = false
        }
    }
    
    private func getRescrapeInfo(force: Bool) -> (shouldRescrape: Bool, savedGroupedEvents: [Date: [BMEventCalendarEntry]]) {
        let savedGroupedEvents = cachedSavedGroupedEvents.isEmpty ? retrieveSavedGroupedEvents() : cachedSavedGroupedEvents
        let currentDate = Date()
        let lastSavedDate = UserDefaults.standard.object(forKey: type.getInfo().lastRefreshDateKey) as? Date ?? currentDate
        let endOfDayDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: lastSavedDate) ?? currentDate
        let rescrape = force || savedGroupedEvents.isEmpty || currentDate >= endOfDayDate
        
        if rescrape {
            UserDefaults.standard.set(currentDate, forKey: type.getInfo().lastRefreshDateKey)
        }
    
        return (rescrape, savedGroupedEvents)
    }
    
    private func retrieveSavedGroupedEvents() -> [Date: [BMEventCalendarEntry]] {
        guard let decodedData = UserDefaults.standard.data(forKey: type.getInfo().URLString) else {
            return [:]
        }
        
        let decodedEvents = NSArray.unsecureUnarchived(from: decodedData) as? [BMEventCalendarEntry] ?? []
        let groupedSavedEvents = groupEventsByDay(decodedEvents)
        return groupedSavedEvents
    }
    
    private func repopulateWithSavedGroupedEvents() {
        let savedGroupedEvents = retrieveSavedGroupedEvents()
        entries = savedGroupedEvents
    }
    
    private func groupEventsByDay(_ events: [BMEventCalendarEntry]) -> [Date: [BMEventCalendarEntry]] {
        let groupedCalendarEntries = Dictionary(grouping: events, by: { $0.date.getStartOfDay() })
        return groupedCalendarEntries
    }
}


// MARK: - WKNavigationDelegate

extension EventScrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard currNumOfRescrapes < allowedNumOfRescrapes else {
            currNumOfRescrapes = 0
            withoutAnimation {
                self.alert = BMAlert(title: "Unable To Load Events", message: "Cannot load events in reasonable time. Please try again later.", type: .notice)
            }
            repopulateWithSavedGroupedEvents()
            isLoading = false
            return
        }
        
        Task {
            do {
                let result = try await webView.evaluateJavaScript("document.body.innerHTML")
            
                guard let htmlContent = result as? String else {
                    await MainActor.run {
                        withoutAnimation {
                            self.alert = BMAlert(title: "Unable To Load Events", message: "Parsing website HTML content was unsuccessful. Please try again.", type: .notice)
                        }
                        repopulateWithSavedGroupedEvents()
                        isLoading = false
                    }
                    return
                }
                
                let scrappedCalendarEntries = try parseWebsiteForEvents(html: htmlContent)

                guard !scrappedCalendarEntries.isEmpty else {
                    currNumOfRescrapes += 1
                    scrape()
                    return
                }
                
                saveEventCalendarEntries(for: scrappedCalendarEntries)
                
                await MainActor.run {
                    entries = groupEventsByDay(scrappedCalendarEntries)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    withoutAnimation {
                        self.alert = BMAlert(title: "Unable To Load Events", message: error.localizedDescription, type: .notice)
                    }
                    repopulateWithSavedGroupedEvents()
                    isLoading = false
                }
            }
        }
    }
    
    private func parseWebsiteForEvents(html: String) throws -> [BMEventCalendarEntry] {
        let doc = try SwiftSoup.parse(html)

        let dateElements = try doc.select("div#lw_cal_events > h3")

        var scrappedCalendarEntries = [BMEventCalendarEntry]()

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
                    
                    if try eventTimeElement.text().contains("All Day") {
                        eventStartTimeDate = Date.getTodayShiftDate(for: dateWithYear, hourComponent: 0, minuteComponent: 0, secondComponent: 0)
                        eventEndTimeDate = Date.getTodayShiftDate(for: dateWithYear, hourComponent: 11, minuteComponent: 59, secondComponent: 59)
                    }
                    
                    let eventTitle = try eventLink.select("div.lw_events_title > a").text()
                    let eventSummaryText = try eventLink.select("div.lw_events_summary").text()
                    
                    let eventLinkElement = try eventLink.select("span.lw_item_thumb > a")
                    let eventLinkHrefString = try eventLinkElement.attr("href")
                    let fullSourceLink = eventLinkHrefString.isEmpty ? nil : "https://events.berkeley.edu" + eventLinkHrefString
                    
                    let imageLink = try eventLinkElement.select("picture.lw_image > img").attr("src")
                    
                    if !eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        let newEventCalendarEntry = BMEventCalendarEntry(name: eventTitle, date: eventStartTimeDate ?? dateWithYear, end: eventEndTimeDate, descriptionText: eventSummaryText, location: locationName, imageURL: imageLink, sourceLink: fullSourceLink)
                        scrappedCalendarEntries.append(newEventCalendarEntry)
                    }
                }
            }
        }
        
        return scrappedCalendarEntries
    }
    
    private func saveEventCalendarEntries(for entries: [BMEventCalendarEntry]) {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: entries, requiringSecureCoding: false) {
            print("success save data")
            UserDefaults.standard.set(encodedData, forKey: type.getInfo().URLString)
        }
    }
}
