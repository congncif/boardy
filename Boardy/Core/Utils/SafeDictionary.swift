//
//  SafeDictionary.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 03/11/2022.
//

import Foundation

final class SafeDictionary<Key: Hashable, Value>: @unchecked Sendable {
    private let storage = Locked<[Key: Value]>([:])

    subscript(key: Key) -> Value? {
        get {
            storage.withLock { dictionary in
                dictionary[key]
            }
        }
        set(newValue) {
            storage.withLock { dictionary in
                dictionary[key] = newValue
            }
        }
    }

    func value(
        forKey key: Key,
        orInsert makeValue: () -> Value
    ) -> Value {
        if let existing = storage.withLock({ $0[key] }) {
            return existing
        }

        let candidate = makeValue()
        return storage.withLock { dictionary in
            if let existing = dictionary[key] {
                return existing
            }
            dictionary[key] = candidate
            return candidate
        }
    }
}
