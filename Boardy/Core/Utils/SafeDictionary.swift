//
//  SafeDictionary.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 03/11/2022.
//

import Foundation

final class SafeDictionary<Key: Hashable, Value> {
    private var dictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "boardy.safe-dictionary.serial-queue")

    subscript(key: Key) -> Value? {
        get {
            var result: Value?
            queue.sync { [weak self] in
                guard let self = self else { return }
                result = self.dictionary[key]
            }
            return result
        }
        set(newValue) {
            queue.sync { [weak self] in
                guard let self = self else { return }
                self.dictionary[key] = newValue
            }
        }
    }
}
