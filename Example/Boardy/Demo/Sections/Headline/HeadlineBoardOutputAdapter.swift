//
//  HeadlineBoardBuilder.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation

protocol HeadlineBoardOutputAdaptable: HeadlineBoardOutput {
    var destination: AnyObject? { get }
}

protocol HeadlineBoardOutputAdapting: HeadlineBoardOutput {
    func connect(adapter: HeadlineBoardOutputAdaptable)
}

final class HeadlineInputAdapter: HeadlineBoardOutputAdaptable {
    weak var target: HeadlineInput?

    init(target: HeadlineInput?) {
        self.target = target
    }

    var destination: AnyObject? { target }

    func receive(label: String) {
        target?.accept(label: label)
    }
}

final class HeadlineBoardOutputAdapter: HeadlineBoardOutputAdapting {
    private var adapters: [HeadlineBoardOutputAdaptable] = []

    func connect(adapter: HeadlineBoardOutputAdaptable) {
        adapters.removeAll { $0.destination == nil }
        adapters.append(adapter)
    }

    func receive(label: String) {
        adapters.removeAll { $0.destination == nil }
        adapters.forEach { $0.receive(label: label) }
    }
}
