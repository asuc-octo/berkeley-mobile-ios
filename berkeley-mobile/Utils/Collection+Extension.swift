//
//  Collection+Extension.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 10/24/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation

/** Ensures safety when indexing into an array. */
extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
      }
}
