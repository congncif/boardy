//
//  NoBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation
import UIKit

public final class NoBoard: Board, ActivatableBoard {
    private let handler: ((Any?) -> Void)?
    private let message: String?

    public init(identifier: BoardID, message: String? = nil, handler: ((Any?) -> Void)? = nil) {
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

public final class NoBoardProducer: ActivableBoardProducer {
    public init() {}

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        return NoBoard(identifier: anotherIdentifier)
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        NoBoard(identifier: identifier)
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
