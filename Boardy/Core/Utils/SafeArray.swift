//
//  SafeArray.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 03/11/2022.
//

import Foundation

final class SafeArray<Value> {
    private var array = [Value]()
    private let queue = DispatchQueue(label: "boardy.safe-array.serial-queue")

    func append(_ newElement: Value) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.array.append(newElement)
        }
    }

    func removeAll() {
        queue.sync { [weak self] in
            guard let self = self else { return }
            self.array.removeAll()
        }
    }

    var isEmpty: Bool {
        var result = true
        queue.sync { [weak self] in
            guard let self = self else { return }
            result = self.array.isEmpty
        }
        return result
    }

    var elements: [Value] {
        var result: [Value] = []
        queue.sync { [weak self] in
            guard let self = self else { return }
            result = self.array
        }
        return result
    }
}
