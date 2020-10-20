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

open class UIMotherboard: Board, UIMotherboardRepresentable, UIMotherboardObservable, BoardDelegate, FlowUIMotherboard {
    var uimainboard: [UIActivatableBoard] = [] {
        didSet {
            for var board in uiboards {
                board.delegate = self
            }
            uiboardsRelay.accept(uiboards)
        }
    }

    var visibleBoards: Observable<[UIChangableBoard]> {
        uiboardsRelay.flatMap {
            Observable.combineLatest($0.map { $0.changeSequence })
                .map {
                    $0.filter { $0.isVisible }
                }
        }
    }

    private lazy var uiboardsRelay = BehaviorRelay<[UIActivatableBoard]>(value: uiboards)

    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                uiboards: [UIActivatableBoard] = []) {
        super.init(identifier: identifier)

        for board in uiboards {
            addUIBoard(board)
        }

        forwardActionFlow(to: self)
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            uiboards: [UIActivatableBoard] = [],
                            rootObject: AnyObject) {
        self.init(identifier: identifier, uiboards: uiboards)
        installIntoRoot(rootObject)
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        for board in uiboards {
            board.installIntoRoot(rootObject)
        }
    }
}
