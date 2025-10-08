//
//  DataManager.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation

/** The list of `DataSource` classes to fetch data from. Add to this list to add new data to the app. */
fileprivate let kDataSources: [DataSource.Type] = [
    MapDataSource.self,
    LibraryDataSource.self,
    GymDataSource.self
]

class DataManager {
    
    /** Singleton instance */
    static let shared = DataManager()
    
    // minimum time between fetches to avoid excessive fetching
    static let fetchInterval: TimeInterval = 60 * 60
    
    private var data: AtomicDictionary<String, [Any]>
    // TODO: Make this O(1).
    var searchable: [SearchItem] {
        data.values.compactMap { (items) -> [SearchItem]? in
            // Handle special case of map markers, which has markers stored in a dictionary
            if let dictItems = items as? [[String: [SearchItem]]] {
                return dictItems.map { dict in
                    dict.values.flatMap { $0 }
                }.flatMap { $0 }
            }
            return items as? [SearchItem]
        }.flatMap { $0 }
    }
    
    private init() {
        data = AtomicDictionary<String, [Any]>()
    }
    
    private func asKey(_ source: DataSource.Type) -> String {
        return String(describing: source)
    }
    
    private var lastFetched: Date?
    func fetchIfNecessary() {
        if let lastFetched = self.lastFetched, Date().timeIntervalSince(lastFetched) < DataManager.fetchInterval {
            return
        }
        fetchAll()
    }
    
    func fetchAll() {
        lastFetched = Date()
        let requests = DispatchGroup()
        for source in kDataSources {
            requests.enter()
            fetch(source: source) { _ in requests.leave() }
        }
    }

    func fetch(source: DataSource.Type, _ completion: @escaping DataSource.completionHandler) {
        // make sure that all data sources are only fetched form Firebase once
        // this also prevents issues with having two objects for the same library overriding each other
        let dispatch = source.fetchDispatch
        dispatch.notify(queue: .global(qos: .utility)) {
            // if data source already loaded, use existing item
            if let items = self.data[self.asKey(source)] {
                DispatchQueue.main.async {
                    completion(items)
                }
            } else {
                // if this is the first time fetching for this source, pause all other fetches and get data from Firebase
                dispatch.enter()
                source.fetchItems { items in
                    self.data[self.asKey(source)] = items
                    DispatchQueue.main.async {
                        dispatch.leave()
                        completion(items)
                    }
                }
            }
        }
    }
    
}
