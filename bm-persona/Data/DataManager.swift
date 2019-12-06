//
//  DataManager.swift
//  bm-persona
//
//  Created by Kevin Hu on 12/5/19.
//  Copyright © 2019 RJ Pimentel. All rights reserved.
//

import Foundation

// Use enum perhaps?
fileprivate let kDataSources: [DataSource.Type] = [GymDataSource.self]

protocol DataSource {
    typealias completionHandler = (_ resources: [Any]?) -> Void
    static func fetchItems(_ completion: @escaping DataSource.completionHandler)
}

class DataManager {
    
    static let shared = DataManager()
    
    var data: [String: [Any]?]
    // TODO: Handle search items somehow.
    
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
        }
        source.fetchItems { items in
            self.data[self.asKey(source)] = items
            completion(items)
        }
    }
    
}
