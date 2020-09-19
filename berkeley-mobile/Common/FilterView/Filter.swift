//
//  Filter.swift
//  bm-persona
//
//  Created by Kevin Hu on 2/11/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

struct Filter<T>: TableFunction {
  
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
                activeFilters.allSatisfy { $0.filter?(datum) ?? true }
            })
        }
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem)
        return workItem
    }
    
    /**
        Filters out datum in `data` that do not satisfy at least one filter in `filters`.

        - Parameter filters:    The list of filters.
        - Parameter data:       An array of data to filter.
        - Parameter indices:    The indices of active filters in `filters`. Setting this value to `nil` activates all filters.
        - Parameter completion: A block to execute with the filtered results.

        - Returns: The `DispatchWorkItem ` encapsulating the work. Use this object to cancel the work if needed.
    */
    static func satisfiesAny(filters: [Filter<T>], on data: [T], indices: [Int]? = nil, completion: @escaping ([T]) -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem {
            let activeFilters = indices?.map { filters[$0] } ?? filters
            completion(data.filter { datum in
                activeFilters.contains { $0.filter?(datum) ?? true }
            })
        }
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem)
        return workItem
    }
  
}
