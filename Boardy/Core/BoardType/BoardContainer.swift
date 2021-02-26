//
//  BoardContainer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/23/20.
//

import Foundation

public final class BoardContainer: ActivableBoardProducer {
    private var externalProducer: ActivableBoardProducer?

    private var container: [BoardID: () -> ActivatableBoard] = [:]

    public init(externalProducer: ActivableBoardProducer? = nil) {
        self.externalProducer = externalProducer
    }

    public func register(_ boardFactory: @escaping () -> ActivatableBoard, forId boardId: BoardID) {
        container[boardId] = boardFactory
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            return boardFactory()
        } else if let board = externalProducer?.produceBoard(identifier: identifier) {
            return board
        } else {
            return NoBoard(identifier: identifier)
        }
    }
}

// MARK: - NoBoard

public final class NoBoard: Board, ActivatableBoard {
    private let handler: ((Any?) -> Void)?

    public init(identifier: BoardID = .randomUnique(), handler: ((Any?) -> Void)? = nil) {
        self.handler = handler
        super.init(identifier: identifier)
    }

    public func activate(withOption option: Any?) {
        let alert = UIAlertController(title: "Feature is coming", message: "Board with identifier \(identifier) was not installed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: { [weak self] _ in
            self?.handler?(option)
        }))
        rootViewController.topPresented.present(alert, animated: true)
    }
}

private extension UIViewController {
    var topPresented: UIViewController {
        if let top = presentedViewController {
            return top.topPresented
        } else {
            return self
        }
    }
}

final class NoBoardProducer: ActivableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        NoBoard(identifier: identifier)
    }
}
