//
//  BoardContainer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/23/20.
//

import Foundation

public final class BoardContainer: ActivableBoardProducer {
    private var externalContainer: BoardContainer?

    private var container: [BoardID: (BoardID) -> ActivatableBoard] = [:]

    public init(externalContainer: BoardContainer? = nil) {
        self.externalContainer = externalContainer
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard) {
        container[identifier] = factory
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            return boardFactory(identifier)
        } else if let board = externalContainer?.produceBoard(identifier: identifier) {
            return board
        } else {
            return nil
        }
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            return boardFactory(anotherIdentifier)
        } else if let board = externalContainer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            return board
        } else {
            return nil
        }
    }
}

// MARK: - NoBoard

public final class NoBoard: Board, ActivatableBoard {
    private let handler: ((Any?) -> Void)?
    private let message: String?

    public init(identifier: BoardID = .randomUnique(), message: String? = nil, handler: ((Any?) -> Void)? = nil) {
        self.handler = handler
        self.message = message
        super.init(identifier: identifier)
    }

    public func activate(withOption option: Any?) {
        let msg = message ?? "Board with identifier \(identifier) was not registered yet!!!"
        let alert = UIAlertController(title: "Feature Not Found", message: msg, preferredStyle: .alert)
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
