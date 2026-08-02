//
//  Locked.swift
//  Boardy
//

import Foundation

/// Reports a Motherboard mutation performed off the main thread, in DEBUG builds only.
///
/// Motherboard state — the installed board list and the flow list — is plain unsynchronized
/// storage. Mutating it from two threads is undefined behavior, not merely a stale read. UIKit
/// callers already run on the main thread, so this is the assumption the framework has always made;
/// the check makes a violation visible during development instead of surfacing later as corruption.
///
/// Deliberately `assert`-based: release builds keep the existing caller-controlled execution
/// contract unchanged, per `docs/API_STABILITY_1X.md`.
@inline(__always)
func boardyAssertMainThread(
    _ function: StaticString = #function,
    file: StaticString = #fileID,
    line: UInt = #line
) {
    #if DEBUG
        assert(
            Thread.isMainThread,
            """
            🔥 [Boardy] \(function) was called off the main thread.
            Motherboard board and flow storage is not synchronized; mutate it from the main thread.
            """,
            file: file,
            line: line
        )
    #endif
}

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
