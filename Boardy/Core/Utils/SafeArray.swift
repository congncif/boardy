//
//  SafeArray.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 03/11/2022.
//

import Foundation

final class SafeArray<Value>: @unchecked Sendable {
    private let storage = Locked<[Value]>([])

    @discardableResult
    func append(_ newElement: Value) -> Bool {
        storage.withLock { values in
            let wasEmpty = values.isEmpty
            values.append(newElement)
            return wasEmpty
        }
    }

    func removeAll() {
        storage.withLock { values in
            values.removeAll()
        }
    }

    func takeAll() -> [Value] {
        storage.withLock { values in
            let result = values
            values.removeAll(keepingCapacity: true)
            return result
        }
    }

    var isEmpty: Bool {
        storage.withLock { values in
            values.isEmpty
        }
    }

    var elements: [Value] {
        storage.withLock { values in
            values
        }
    }
}
