//
//  DataManager.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation

fileprivate let kDataSources: [DataSource.Type] = [
    MapDataSource.self,
    ResourceDataSource.self,
    LibraryDataSource.self,
    GymDataSource.self,
    CalendarDataSource.self
]

class DataManager {
    
    static let shared = DataManager()
    
    var data: [String: [Any]]
    // TODO: Make this O(1).
    var searchable: [SearchItem] {
        data.values.compactMap { items in
            items as? [SearchItem]
        }.flatMap { $0 }
    }
    
    private init() {
        data = [:]
    }
    
    private func asKey(_ source: DataSource.Type) -> String {
        return String(describing: source)
    }
    
    func fetchAll() {
        for source in kDataSources {
            fetch(source: source) { _ in }
        }
    }

    func fetch(source: DataSource.Type, _ completion: @escaping DataSource.completionHandler) {
        if let items = data[asKey(source)] {
            completion(items)
        } else {
            source.fetchItems { items in
                self.data[self.asKey(source)] = items
                completion(items)
            }
        }
    }
    
}
