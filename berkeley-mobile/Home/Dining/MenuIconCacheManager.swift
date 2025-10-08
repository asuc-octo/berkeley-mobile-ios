//
//  MenuIconCacheManager.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 10/6/25.
//  Copyright © 2025 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

protocol MenuItemIconCaching: AnyObject {
    func fetchMenuIconImage(for urlString: String) async throws -> UIImage?
    func fetchMenuIconImages(for urlStrings: [String]) async -> [UIImage]
}

/// `MenuItemIconCacheManager` caches the menu item food icons for more efficient retrivial.
class MenuItemIconCacheManager: MenuItemIconCaching {
    private var cacheDict: [String: UIImage] = [:]
    
    func fetchMenuIconImage(for urlString: String) async throws -> UIImage? {
        if let cachedImage = cacheDict[urlString] {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let (iconData, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: iconData) else {
            return nil
        }
        
        cacheDict[urlString] = image
        
        return image
    }
    
    func fetchMenuIconImages(for urlStrings: [String]) async -> [UIImage] {
        var results = Array<UIImage?>(repeating: nil, count: urlStrings.count)
        var toFetch: [(index: Int, key: String, url: URL)] = []

        for (i, key) in urlStrings.enumerated() {
            if let cached = cacheDict[key] {
                results[i] = cached
            } else if let url = URL(string: key) {
                toFetch.append((i, key, url))
            } else {
                results[i] = nil
            }
        }

        await withTaskGroup(of: (Int, String, UIImage?).self) { group in
            for item in toFetch {
                group.addTask {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: item.url)
                        return (item.index, item.key, UIImage(data: data))
                    } catch {
                        return (item.index, item.key, nil)
                    }
                }
            }

            for await (index, key, image) in group {
                if let image {
                    results[index] = image
                    cacheDict[key] = image
                } else {
                    results[index] = nil
                }
            }
        }

        return results.compactMap { $0 }
    }
}
