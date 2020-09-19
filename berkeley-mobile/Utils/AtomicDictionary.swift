//
//  AtomicDictionary.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/16/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import Foundation

// Maybe generalize this functionality for other types using a propertyWrapper or a generic?

/** A simple wrapper for a Dictionary that applies a read-write lock. */
class AtomicDictionary<Key: Hashable, Value> {
    
    /** The internal dictionary to operate on. */
    private var dict: [Key: Value]
    
    /** Read-write lock. */
    private var rwlock: pthread_rwlock_t
    
    init() {
        dict = [:]
        rwlock = pthread_rwlock_t()
        pthread_rwlock_init(&rwlock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&rwlock)
    }
    
}

// MARK: - Public Dictionary Methods

extension AtomicDictionary {
    
    @inlinable public var values: Dictionary<Key, Value>.Values {
        pthread_rwlock_rdlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        return dict.values
    }
    
    @inlinable public subscript(key: Key) -> Value? {
        get {
            pthread_rwlock_rdlock(&rwlock)
            defer { pthread_rwlock_unlock(&rwlock) }
            return dict[key]
        }
        set {
            pthread_rwlock_wrlock(&rwlock)
            defer { pthread_rwlock_unlock(&rwlock) }
            dict[key] = newValue
        }
    }
    
}
