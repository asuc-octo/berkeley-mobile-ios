//
//  EventScrapper.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/6/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

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
    
    @Published var groupedEntries: [Date: [BMEventCalendarEntry]] = [:]
    @Published var isLoading = false
    @Published var alert: BMAlert?
    
    var groupedEntriesSortedKeys: [Date] {
        groupedEntries.keys.sorted()
    }
    
    var allEntries: [BMEventCalendarEntry] {
        groupedEntries.flatMap { $0.1 }
    }
    
    let type: EventScrapperType
    
    /// Allowed number of rescrapes until `EventScrapper` gives up on scrapping.
    private var allowedNumOfRescrapes = 5
    private var currNumOfRescrapes = 0
    private var cachedSavedGroupedEvents: [Date: [BMEventCalendarEntry]] = [:]
    
    lazy private var webView: WKWebView = {
        let prefs = WKPreferences()
        prefs.javaScriptCanOpenWindowsAutomatically = true
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    /// JavaScript that extracts event data directly from the DOM using the browser's native querySelector APIs.
    /// Loaded from EventExtraction.js bundle resource.
    private static let eventExtractionJS: String = {
        guard let url = Bundle.main.url(forResource: "EventExtraction", withExtension: "js"),
              let js = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("EventExtraction.js not found in bundle")
        }
        return js
    }()
    
    init(type: EventScrapperType, allowedNumOfRescrapes: Int = 5) {
        self.type = type
        self.allowedNumOfRescrapes = allowedNumOfRescrapes
        super.init()
        webView.navigationDelegate = self
    }
    
    func scrape(forceRescrape: Bool = false) {
        guard let url = URL(string: type.getInfo().URLString) else {
            return
        }
    
        isLoading = true
        
        groupedEntries.removeAll()
        
        let rescrapeInfo = getRescrapeInfo(force: forceRescrape)
        
        if rescrapeInfo.shouldRescrape {
            webView.load(URLRequest(url: url))
        } else {
            groupedEntries = rescrapeInfo.savedGroupedEvents
            isLoading = false
        }
    }
    
    private func getRescrapeInfo(force: Bool) -> (shouldRescrape: Bool, savedGroupedEvents: [Date: [BMEventCalendarEntry]]) {
        let savedGroupedEvents = cachedSavedGroupedEvents.isEmpty ? retrieveSavedGroupedEvents() : cachedSavedGroupedEvents
        let currentDate = Date()
        let lastSavedDate = UserDefaults.standard.object(forKey: type.getInfo().lastRefreshDateKey) as? Date ?? currentDate
        let endOfDayDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: lastSavedDate) ?? currentDate
        let rescrape = force || savedGroupedEvents.isEmpty || currentDate >= endOfDayDate
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
        groupedEntries = savedGroupedEvents
    }
    
    private func groupEventsByDay(_ events: [BMEventCalendarEntry]) -> [Date: [BMEventCalendarEntry]] {
        let groupedCalendarEntries = Dictionary(grouping: events, by: { $0.startDate.getStartOfDay() })
        return groupedCalendarEntries
    }
}


// MARK: - WKNavigationDelegate

extension EventScrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard currNumOfRescrapes < allowedNumOfRescrapes else {
            currNumOfRescrapes = 0
            alert = BMAlert(title: "Unable To Load Events", message: "Cannot load events in reasonable time. Please try again later.", type: .notice)
            repopulateWithSavedGroupedEvents()
            isLoading = false
            return
        }
        
        Task { @MainActor in
            defer {
                isLoading = false
            }
            
            do {
                // Poll for JS-rendered content. The didFinish callback fires before
                // LiveWhale JS populates events, so we retry up to a max wait time.
                let maxAttempts = 6
                let pollInterval: UInt64 = 500_000_000 // 0.5 seconds
                var events: [[String: Any]]?
                
                for _ in 0..<maxAttempts {
                    try await Task.sleep(nanoseconds: pollInterval)
                    
                    let result = try await webView.evaluateJavaScript(Self.eventExtractionJS)
                    
                    if let jsonString = result as? String,
                       let data = jsonString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let parsed = json["events"] as? [[String: Any]],
                       !parsed.isEmpty {
                        events = parsed
                        break
                    }
                }
                
                guard let events, !events.isEmpty else {
                    currNumOfRescrapes += 1
                    scrape(forceRescrape: true)
                    return
                }
                
                let entries = convertJSEventsToBMEntries(events)
                
                guard !entries.isEmpty else {
                    currNumOfRescrapes += 1
                    scrape(forceRescrape: true)
                    return
                }
                
                currNumOfRescrapes = 0
                saveEventCalendarEntries(for: entries)
                groupedEntries = groupEventsByDay(entries)
            } catch {
                alert = BMAlert(title: "Unable To Load Events", message: error.localizedDescription, type: .notice)
                repopulateWithSavedGroupedEvents()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        alert = BMAlert(title: "Unable To Load Events", message: error.localizedDescription, type: .notice)
        repopulateWithSavedGroupedEvents()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        alert = BMAlert(title: "Unable To Load Events", message: error.localizedDescription, type: .notice)
        repopulateWithSavedGroupedEvents()
    }
}


// MARK: - Event Parsing

extension EventScrapper {
    
    private static let baseURL = "https://events.berkeley.edu"
    
    private static let monthMap: [String: Int] = [
        "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4,
        "May": 5, "Jun": 6, "Jul": 7, "Aug": 8,
        "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12
    ]
    
    private func convertJSEventsToBMEntries(_ events: [[String: Any]]) -> [BMEventCalendarEntry] {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return events.compactMap { event in
            guard let title = event["title"] as? String, !title.isEmpty else { return nil }
            
            let source = event["source"] as? String ?? ""
            let dateText = event["dateText"] as? String ?? ""
            let timeText = event["time"] as? String ?? ""
            let location = event["location"] as? String ?? ""
            let summary = event["summary"] as? String ?? ""
            let href = event["href"] as? String ?? ""
            let imgSrc = event["imgSrc"] as? String ?? ""
            
            let eventDate = parseEventDate(dateText, source: source, year: currentYear)
            let cleanedTime = source == "card"
                ? timeText.replacingOccurrences(of: "Time:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                : timeText
            let (startDate, endDate) = parseTimeText(cleanedTime, baseDate: eventDate)
            
            return BMEventCalendarEntry(
                name: title,
                date: startDate ?? eventDate,
                end: endDate,
                descriptionText: summary.isEmpty ? nil : summary,
                location: location.isEmpty ? nil : location,
                imageURL: Self.buildFullURL(href: imgSrc),
                sourceLink: Self.buildFullURL(href: href)
            )
        }
    }
    
    private func parseEventDate(_ dateText: String, source: String, year: Int) -> Date {
        if source == "card" {
            return parseCardDate(dateText, year: year) ?? Date()
        }
        
        // LiveWhale format: "Sunday, March 1"
        if let parsed = dateText.convertToDate(dateFormat: "EEEE, MMMM d"),
           let withYear = Date.setYear(year, to: parsed) {
            return withYear
        }
        
        return Date()
    }
    
    private func parseCardDate(_ text: String, year: Int) -> Date? {
        let parts = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        guard parts.count == 2,
              let month = Self.monthMap[parts[0]],
              let day = Int(parts[1]) else { return nil }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
    
    private func parseTimeText(_ timeText: String, baseDate: Date) -> (start: Date?, end: Date?) {
        let cleaned = timeText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleaned.isEmpty else {
            return (nil, nil)
        }
        
        if cleaned.lowercased().contains("all day") {
            let start = Date.getTodayShiftDate(for: baseDate, hourComponent: 0, minuteComponent: 0, secondComponent: 0)
            let end = Date.getTodayShiftDate(for: baseDate, hourComponent: 23, minuteComponent: 59, secondComponent: 59)
            return (start, end)
        }
        
        let parts = cleaned.components(separatedBy: " - ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard let startPart = parts.first, !startPart.isEmpty else {
            return (nil, nil)
        }
        
        let endPart = parts.count > 1 ? parts[1] : nil
        
        // Strip date prefixes for multi-day events
        let startTimeString = Self.stripDatePrefix(startPart)
        let endTimeString = endPart.map { Self.stripDatePrefix($0) }
        
        let startDate = startTimeString.convertTimeStringToDate(baseDate: baseDate, endTimeString: endTimeString)
        let endDate = endTimeString?.convertTimeStringToDate(baseDate: baseDate)
        
        return (startDate, endDate)
    }
    
    /// Strips a date prefix like "Feb 28, " or "Mar 1, " from a time string.
    private static func stripDatePrefix(_ text: String) -> String {
        let pattern = "^[A-Z][a-z]{2}\\s+\\d{1,2},\\s*"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range.upperBound...])
        }
        return text
    }
    
    private static func buildFullURL(href: String?) -> String? {
        guard let href, !href.isEmpty else { return nil }
        return href.hasPrefix("http") ? href : baseURL + href
    }
}


// MARK: - Persistence

extension EventScrapper {
    private func saveEventCalendarEntries(for entries: [BMEventCalendarEntry]) {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: entries, requiringSecureCoding: false) {
            UserDefaults.standard.set(Date(), forKey: type.getInfo().lastRefreshDateKey)
            UserDefaults.standard.set(encodedData, forKey: type.getInfo().URLString)
        }
    }
}
