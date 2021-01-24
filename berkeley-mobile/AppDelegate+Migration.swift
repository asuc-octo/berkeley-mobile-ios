//
//  AppDelegate+Migration.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 9/24/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import Firebase

// MARK: Version

/// Struct to store and compare version information.
///
/// This is intended for release versions, so build number is excluded.
struct Version: Comparable {
    /// The major revision number.
    var major: Int
    /// The minor revision number.
    var minor: Int
    /// A maintenance release number.
    var patch: Int

    static func < (lhs: Version, rhs: Version) -> Bool {
        return lhs.major < rhs.major || (lhs.major == rhs.major &&
            (lhs.minor < rhs.minor || (lhs.minor == rhs.minor &&
            lhs.patch < rhs.patch)))
    }

    /// Parses `version`, which is expected to be in the format: `[Major].[Minor].[Patch]`.
    init(version: String) {
        let components: [Int] = version.split(separator: ".").map { Int($0) ?? 0 }
        self.major = components.count > 0 ? components[0] : 0
        self.minor = components.count > 1 ? components[1] : 0
        self.patch = components.count > 2 ? components[2] : 0
    }
}

// MARK: Migrations

/// The `UserDefaults` key for the last app version ran on this device.
fileprivate let kLatestLaunchedVersionKey = "LatestLaunchedVersion"

extension AppDelegate {

    /// Check if the app has been updated since the last launch, and perform any necessary migrations.
    ///
    /// This function should not be trimmed of old migrations.
    internal func checkForUpdate() {
        // Get current and last seen versions
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let lastVersion = UserDefaults.standard.string(forKey: kLatestLaunchedVersionKey) ?? "0.0.0"
        let last = Version(version: lastVersion), current = Version(version: currentVersion)
        guard current > last else { return }
        let group = DispatchGroup()
        var failed = false

        // Begin migrations
        group.enter()
        if last < Version(version: "10.0.1") {
            // https://www.notion.so/KERN_INVALID_ADDRESS-segfault-3ca79b7958424e32b36929009c2ca5c6
            clearCache { success in
                // Since this block is called on the main thread, no need to synchronize accesses to `failed`
                failed = failed || !success
                group.leave()
            }
        }
        if last < Version(version: "10.0.4") {
            
        }

        // Only update the last seen version if all migrations are successful
        group.notify(queue: .main) {
            if !failed {
                UserDefaults.standard.set(currentVersion, forKey: kLatestLaunchedVersionKey)
            }
        }
    }

    // MARK: Migration Actions

    /**
      Clear any persistent data. Do not reset UserDefaults in this function. Caches to clear: Analytics, Firestore.
      - Parameter completion: A completion block called on the main thread indicating whether the cache clear succeeded.
     */
    private func clearCache(completion: ((Bool) -> Void)?) {
        Analytics.resetAnalyticsData()
        Firestore.firestore().clearPersistence { err in
            if let err = err {
                print("[Error @ AppDelegate.clearCache()]: \(err)")
            }
            completion?(err == nil)
        }
    }
}
