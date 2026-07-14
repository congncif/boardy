//
//  Locked.swift
//  Boardy
//

import Foundation

/// Synchronous storage boundary. The wrapped value is accessible only through
/// `withLock`, and callers must not invoke external callbacks from its critical section.
final class Locked<Value>: @unchecked Sendable {
    private var value: Value
    private let lock = NSLock()

    init(_ value: Value) {
        self.value = value
    }

    @discardableResult
    func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}
