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
        let title = "Feature Not Found"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: { [weak self] _ in
            self?.handler?(option)
            self?.complete()
        }))
        rootViewController.boardy_topPresentedViewController.present(alert, animated: true)

        #if DEBUG
            print("⚠️ [NoBoard] \(title) - \(msg) ‼️")
        #endif
    }

    public func shouldBypassGatewayBarrier() -> Bool {
        true
    }
}

public final class NoBoardProducer: ActivatableBoardProducer {
    public init() {}

    public func produceGatewayBoard(identifier _: BoardID) -> (any ActivatableBoard)? {
        nil
    }

    public func matchBoard(withIdentifier _: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        NoBoard(identifier: anotherIdentifier)
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        NoBoard(identifier: identifier)
    }
}
