//
//  UIMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxRelay
import RxSwift
import UIKit

open class UIMotherboard: Board, UIMotherboardRepresentable, UIMotherboardObservable, BoardDelegate, FlowManageable {
    var uimainboard: [BoardID: UIActivatableBoard] = [:] {
        didSet {
            self.uiboardsRelay.accept(uiboards)
        }
    }

    var visibleBoards: Observable<[UIActivatableBoard]> { self.uiboardsRelay.asObservable() }

    private lazy var uiboardsRelay = BehaviorRelay<[UIActivatableBoard]>(value: uiboards)

    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                uiboards: [UIActivatableBoard] = []) {
        super.init(identifier: identifier)

        for var board in uiboards {
            self.addUIBoard(board)
            board.delegate = self
        }
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            uiboards: [UIActivatableBoard] = [],
                            rootViewController: UIViewController) {
        self.init(identifier: identifier, uiboards: uiboards)
        self.install(into: rootViewController)
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        for board in self.uiboards {
            board.install(into: rootViewController)
        }
    }
}
