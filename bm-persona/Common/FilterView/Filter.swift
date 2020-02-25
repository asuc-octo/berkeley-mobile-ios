//
//  Filter.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/11/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

struct Filter<T> {
  
    var label: String
    var filter: ((T) -> Bool)?
    
    /**
        Applies filters in `filters` to `data`.

        - Parameter filters:    The filters to apply.
        - Parameter data:       An array of data to filter.
        - Parameter indices:    The indices of active filters in `filters`. Setting this value to `nil` activates all filters.
        - Parameter completion: A block to execute with the filtered results.

        - Returns: The `DispatchWorkItem ` encapsulating the work. Use this object to cancel the work if needed.
    */
    static func apply(filters: [Filter<T>], on data: [T], indices: [Int]? = nil, completion: @escaping ([T]) -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            let activeFilters = indices?.map { filters[$0] } ?? filters
            completion(data.filter { datum in
                // I don't think this short-circuits. Change this if that ever becomes a big enough issue.
                activeFilters.map { $0.filter?(datum) ?? true }.allSatisfy { $0 == true }
            })
        }
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem)
        return workItem
    }
  
}
