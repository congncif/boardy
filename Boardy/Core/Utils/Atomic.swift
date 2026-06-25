//
//  Atomic.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/16/21.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {
    private var value: Value
    private let lock = NSRecursiveLock()

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
        get { get() }
        set { set(newValue) }
    }

    func get() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func set(_ newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }

    mutating func mutate<Result>(_ mutation: (inout Value) -> Result) -> Result {
        lock.lock()
        defer { lock.unlock() }
        return mutation(&value)
    }
}

extension Atomic where Value: Equatable {
    mutating func compareAndSet(expected: Value, desired: Value) -> Bool {
        mutate { value in
            guard value == expected else { return false }
            value = desired
            return true
        }
    }
}
